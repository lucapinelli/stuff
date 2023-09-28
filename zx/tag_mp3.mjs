#!/usr/bin/env zx
// zx version 4.2.0

/* global argv, question, $ */

const showHelp = () => {
  console.info(`
USAGE:
  tag_mp3.mjs *.mp3
`)
}

const { help, h } = argv
const [scriptPath, ...files] = argv._ // eslint-disable-line no-unused-vars

const forEach = async (list, asyncFn) => {
  if (!list) {
    return
  }
  for (let i = 0; i < list.length; ++i) {
    await asyncFn(list[i], i, list)
  }
}

const generateMeta = (file) => {
  const dashIndex = file.indexOf('-')
  const dotIndex = file.lastIndexOf('.')
  if (dashIndex < 0 || dotIndex < 0) {
    return {}
  }
  const artist = file.substring(0, dashIndex).trim()
  const title = file.substring(dashIndex + 1, dotIndex).trim()
  return { artist, title }
}

const main = async () => {
  if (help || h || files.length === 0) {
    showHelp()
    return
  }

  files.forEach(file => {
    const { artist, title } = generateMeta(file)
    if (!artist || !title) {
      console.warn('file "%s" discarded.', file)
      return
    }
    console.info(file, '::', { artist, title })
  })
  const proceed = await question(
    '\nDo you want to tag the files [y/n] (default n)? ',
    { choices: ['y', 'n'] }
  )
  if (proceed !== 'y') {
    console.info('terminated.')
    return
  }
  await forEach(files, async file => {
    const { artist, title } = generateMeta(file)
    if (!artist || !title) {
      return
    }
    await $`eyeD3 --artist ${artist} --title ${title} ${file}`
  })
  console.info('terminated.')
}

main().catch(e => console.error('\n[FATAL]', e))

#!/usr/bin/env zx
// zx version 4.2.0

/* global argv, question, $ */

$.verbose = false

const showHelp = () => {
  console.info(`
USAGE:
  sync_playlist.mjs "Sunday morning.m3u" "/media/luca/USB PEN DRIVE XYZ"
`)
}

const forEach = async (list, asyncFn) => {
  if (!list) {
    return
  }
  for (let i = 0; i < list.length; ++i) {
    await asyncFn(list[i], i, list)
  }
}

const { help, h } = argv
const [scriptPath, playlist, dest] = argv._ // eslint-disable-line no-unused-vars

const getFileName = filePath => filePath.replace(/^.*\/([^/]+)$/, '$1')

const main = async () => {
  if (help || h || !playlist || !dest) {
    showHelp()
    return
  }
  const sourceFiles = (await $`cat ${playlist}`).stdout.split('\n').filter(Boolean)
  const destFiles = (await $`ls ${dest}`).stdout.split('\n').filter(Boolean)

  const toCopy = sourceFiles.filter(file => !destFiles.find(f => f === getFileName(file)))
  const toDelete = destFiles.filter(file => !sourceFiles.find(f => getFileName(f) === file))

  toCopy.forEach(file => console.info('copy', file))
  toDelete.forEach(file => console.info('delete', file))

  if (toCopy.length === 0 && toDelete.length === 0) {
    console.info('Nothing to sync. Terminated.')
    return
  }

  const proceed = await question(
    '\nDo you want to proceed [y/n] (default n)? ',
    { choices: ['y', 'n'] }
  )
  if (proceed !== 'y') {
    console.info('Terminated.')
    return
  }

  await forEach(toDelete, async file => {
    await $`rm ${dest + '/' + file}`
    console.info(file, 'deleted')
  })
  await forEach(toCopy, async file => {
    await $`cp ${file} ${dest + '/' + getFileName(file)}`
    console.info(file, 'copied')
  })

  console.info('Terminated.')
}

main().catch(e => console.error('\n[FATAL]', e))

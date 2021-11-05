#!/usr/bin/env zx
// zx version 4.2.0

/* global argv, question, $ */

$.verbose = false

const showHelp = () => {
  console.info(`
USAGE:
  sync_folder.mjs /media/Music/miscellaneous /media/phone/Music/miscellaneous
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
const [scriptPath, source, dest] = argv._ // eslint-disable-line no-unused-vars

const main = async () => {
  if (help || h || !source || !dest) {
    showHelp()
    return
  }
  const sourceFiles = (await $`ls ${source}`).stdout.split('\n').filter(Boolean)
  const destFiles = (await $`ls ${dest}`).stdout.split('\n').filter(Boolean)

  const toCopy = sourceFiles.filter(file => !destFiles.find(f => f === file))
  const toDelete = destFiles.filter(file => !sourceFiles.find(f => f === file))

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

  await forEach(toCopy, async file => {
    await $`cp ${source + '/' + file} ${dest + '/' + file}`
    console.info(file, 'copied')
  })
  await forEach(toDelete, async file => {
    await $`rm ${dest + '/' + file}`
    console.info(file, 'deleted')
  })

  console.info('Terminated.')
}

main().catch(e => console.error('\n[FATAL]', e))

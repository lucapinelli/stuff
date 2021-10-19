#!/usr/bin/env zx
// zx version 4.2.0

/* global argv $ */

const log = {
  debug: (...args) => {
    if (argv.debug === true) {
      console.debug(...args)
    }
  },
  info: console.info,
  error: console.error
}

if (argv.info) {
  log.info('rn version 0.1.0')
  process.exit(0)
}

if (argv.help || argv.h || argv._.length !== 3) {
  log.info(`
  NAME
    rn.mjs - rename files ad directory

  SYNOPSIS
    rn.mjs SEARCH REPLACE

  OPTIONS
    --simulate  print names of files to be renamed, but don't rename.
    --fd        argument to pass to the \`fd\` command
    --debug     print debug info
    --verbose   prints all executed commands alongside with their outputs
    --help      display this help and exit
    --info      output version information and exit
  `)
  process.exit(0)
}

// eslint-disable-next-line no-unused-vars
const [_, search, replace] = argv._

$.verbose = argv.verbose === true

log.debug('🤖 argv', argv)

// the main is implemented only to remove the eslint fatal error "Cannot use keyword 'await' outside an async function"
const main = async () => {
  try {
    const list = (await $`fd ${argv.fd}`).stdout.split('\n').filter(Boolean)
    if (!list.length && argv.fd) {
      log.info('🤖 no files matches the fd filter.')
    }
    let file = null; let rename = null
    for (let i = 0; i < list.length; ++i) {
      file = list[i]
      rename = file.replace(new RegExp(search), replace)
      log.info('🤖 file       %s', file)
      log.info('   renamed as %s\n', rename)
      if (!argv.simulate) {
        await $`mv ${file} ${rename}`
      }
    }
  } catch (error) {
    error.stdout && log.info('🤖 out :: ', error.stdout)
    error.stderr && log.error('🤖 error ::', error.stderr)
    process.exit(error.exitCode)
  }
}

main()

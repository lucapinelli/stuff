#!/usr/bin/env zx
// zx version 4.2.0

/* global $ */

const minimist = require('minimist')

const printInfo = () => {
  console.info('rn version 0.2.0')
  process.exit(0)
}

const printHelp = () => {
  console.info(`
    NAME
      rn.mjs - rename files and directories

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

const args = minimist(
  process.argv.slice(3),
  {
    boolean: ['simulate', 'debug', 'verbose', 'help', 'info'],
    string: ['fd']
  }
)
const [search, replace, unknown] = args._
const { simulate, fd, debug, verbose, help, info } = args
$.verbose = verbose

if (help || unknown) {
  printHelp()
}
if (info) {
  printInfo()
}

const log = {
  debug: (...args) => {
    if (debug === true) {
      console.debug(...args)
    }
  },
  info: console.info,
  error: console.error
}

log.debug('🤖 args %j', {
  simulate, fd, debug, verbose, help, info, search, replace
})

// the main is implemented only to remove the eslint fatal error "Cannot use keyword 'await' outside an async function"
const main = async () => {
  try {
    const list = (await $`fd ${fd || ''}`).stdout.split('\n').filter(Boolean)
    if (!list.length && fd) {
      log.info('🤖 no files matches the fd filter.')
    }
    let file = null; let rename = null
    for (let i = 0; i < list.length; ++i) {
      file = list[i]
      rename = file.replace(new RegExp(search), replace)
      if (file !== rename) {
        log.info('🤖 file       %s', file)
        log.info('   renamed as %s', rename)
        if (!simulate) {
          await $`mv ${file} ${rename}`
        }
      }
    }
  } catch (error) {
    error.stdout && log.info('🤖 out :: ', error.stdout)
    error.stderr && log.error('🤖 error ::', error.stderr)
    process.exit(error.exitCode)
  }
}

main()

#!/usr/bin/env node

const { get, merge, pick: loPick, set } = require('lodash')

const beautify = require('beautify')

const help=`
USAGE: curl ... | formatCurl [options]

OPTIONS:
  pick      properties to pick (it will be applied only if the output is a valid JSON)
  format    if the output is a valid JSON Array each json will be print in one line
  help      show this help (other alias for this option are --help, -help)

Example:
  curl ... | formatCurl pick='[*].id,[*].name' format=compact
`
const fs = require('fs')

const getArg = (argName) => {
    const arg = process.argv.find(arg => arg.startsWith(argName + '='))
    if (!arg) {
        return null
    }
    return arg.substring(argName.length + 1)
}

const pick = (object, paths) => {
    if (!paths) {
        return object
    }
    if (!Array.isArray(paths)) {
        paths = [paths] // eslint-disable-line no-param-reassign
    }
    if (Array.isArray(object)) {
        const array = []
        for (const path of paths) {
            const property = path.replace(/^\[\*\]./, '')
            for (let i = 0; i < object.length; ++i) {
                array[i] = merge(array[i], pick(object[i], property))
            }
        }
        return array
    }
    let picked = {}
    for (const path of paths) {
        if (path.includes('[*]')) {
            const tokens = path.split('[*]')
            const accessor = tokens.shift()
            const property = tokens.join('[*]').replace(/^\./, '')
            const array = accessor ? get(object, accessor) : object
            if (!Array.isArray(array)) {
                continue
            }
            const filtered = array.map(item => pick(item, property))
            const pickedArray = get(picked, accessor, [])
            merge(pickedArray, filtered)
            set(picked, accessor, pickedArray)
        }
        picked = merge(picked, loPick(object, path))
    }
    return picked
};

if (process.argv.find(arg => arg === 'help' || arg === '--help' || arg === '-help')) {
    console.log(help)
    return
}

let properties = getArg('pick')
properties = properties && properties.split(',')
const format = getArg('format')

const stdinBuffer = fs.readFileSync(0) // STDIN_FILENO = 0
const text = stdinBuffer.toString()

console.log('\n### Response ###\n')
if (text) {
  try {
      let json = JSON.parse(text)
      json = properties ? pick(json, properties) : json
      if (format === 'compact') {
          if (Array.isArray(json)) {
              console.log('[')
              json.forEach(j => console.log('  ' + JSON.stringify(j)))
              console.log(']')
          } else {
              console.log(JSON.stringify(json))            
          }
      } else {
          console.log(JSON.stringify(json, null, 2))
      }

      if (Array.isArray(json)) {
        console.log('')
        console.log('#' + json.length + ' records')
      }
  } catch (e) {
      console.log(beautify(text, {format: 'html'}))
  }
}
console.log('')

#!/usr/bin/env zx
// zx version 7.2.3

// usage:
// docker logs container_name | docker_pretty.mjs

let content = await stdin()
content.split('\n').forEach(line => {
  let jsonLine = null
  try {
    jsonLine = JSON.parse(line)
  } catch (e) {
    console.log('(text)', line)
    return
  }
  if (jsonLine.log) {
    console.log('(.log)', jsonLine.log.replace(/\n$/, ''))      
  } else if (jsonLine.msg) {
    let { level, time, pid, hostname, reqId, req, res, responseTime, msg } = jsonLine
    level = ({
      10: ' (trace)',
      20: ' (debug)',
      30: ' (info)',
      40: ' (warn)',
      50: ' (error)',
      60: ' (fatal)',
    })[level] || ''
    reqId = reqId || ''
    responseTime = responseTime ? `responseTime=${responseTime}` : ''
    console.log('(.msg)' + level, reqId, msg, req || res, responseTime)
  } else {
    console.log('(json)', jsonLine)      
  }
})

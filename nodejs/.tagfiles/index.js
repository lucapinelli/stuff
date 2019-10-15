#!/usr/bin/env node

const mime = require('mime');

const util = require('util');
const child_process = require('child_process');
const fs = require('fs');


const exec = util.promisify(child_process.exec);

const usage = `
usage:
  tagfiles [options]

options:
  --error-only      do not print stdout but just stderr and exceptions.
  --exception-only  do not print stdout and stderr but just exceptions.
`

async function asyncSeries(values, asyncCallback) {
    let index = 0;
    await values.reduce(async (promise, value) => {
        await promise;
        await asyncCallback(value, index);
    }, Promise.resolve());
}

const main = async () => {

    const options = new Set(process.argv.slice(2));
    if (options.has('--help')) {
        console.log(usage);
        return;
    }
    const errorOnly = options.has('--error-only');
    const exceptionOnly = options.has('--exception-only');

    const files = fs.readdirSync('.');
    asyncSeries(files, async (file) => {
        const mimeType = mime.getType(file);
        const index = file.indexOf('-');
        const lastIndex = file.lastIndexOf('.');
        if (mimeType && mimeType.startsWith('audio/') && index > 0 && lastIndex > index) {
            // .replace(/[\u0250-\ue007]/g, '') removes not latin characters
            const author = file.substring(0, index).trim().replace(/[\u0250-\ue007]/g, '');
            const title = file.substring(index + 1, lastIndex).trim().replace(/[\u0250-\ue007]/g, '');
            const command = `eyeD3 -a "${author}" -t "${title}" "${file}"`;
            console.log('\n', command, '\n');
            try {
                const out = await exec(command);
                if (!errorOnly && !exceptionOnly && out.stdout) {
                    console.log(out.stdout);
                }
                if (!exceptionOnly && out.stderr) {
                    console.log(out.stderr);
                }
            } catch(e) {
                console.log('ERROR');
                console.log(e);
            }
        }
    });
}

main().catch(e => console.log('An error occured:', e));

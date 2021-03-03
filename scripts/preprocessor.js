/**
 * simple text preprocessor for solidity files
 * extends https://www.npmjs.com/package/preprocessor with inline includes.
 */

const fs = require('fs');
const Preprocessor = require('preprocessor');
const optimist = require('optimist');
const path = require('path');

included = {};

function solProcessor(sourceDir, destDir, inputfile, outputfile, defines) {
    let content = fs.readFileSync(sourceDir + inputfile).toString();

    const matches = content.match(/import\s+['"]([^'"]+)['"];/g);
    const includes = [];
    for (const idx in matches) {
        const filename = matches[idx].slice(8, -2);
        if (typeof includes[filename] === 'undefined') {
            let subDir = path.dirname(filename);
            let subfilename = path.basename(filename);
            let fullpath = sourceDir + subDir + "/";

            let norm = path.normalize(fullpath + subfilename);

            if (included[norm]) {
                // console.log("duplicated " + norm);
                includes[filename] = "";
            } else {
                included[norm] = 1;

                let subsource = solProcessor(fullpath, destDir, subfilename);

                includes[filename] = subsource;
            }
        }

        content = content.replace(matches[idx], includes[filename]);
    }

    return new Preprocessor(content).process(defines);
}

function removePragmas(content) {
    const matches = content.split(/(pragma solidity .*;)/g);
    let result = '';
    for (const idx in matches) {
        if (idx % 2 == 0 || idx == 1) {
            result += matches[idx];
        }
    }
    return result;
}

function removeSPDX(content) {
    const matches = content.split(/(\/\/ SPDX-License-Identifier: .*)/g);
    let result = '';
    for (const idx in matches) {
        if (idx % 2 == 0 || idx == 1) {
            result += matches[idx];
        }
    }
    return result;
}

function removeEmptyLines(content) {
    return content.replace(/[\n]{4,}/g, '\n\n\n');
}

function preprocessContracts(sourceDir, destinationDir, defines) {

    const contracts = fs.readdirSync(sourceDir)
        .filter(elem => elem.match(/.sol$/));

    for (let idx in contracts) {
        included = {};
        console.log("Processing " + sourceDir + contracts[idx]);
        const flattened = solProcessor(
            sourceDir,
            destinationDir,
            contracts[idx],
            defines
        );
        const cleanSource = removeEmptyLines(removeSPDX(removePragmas(flattened)));
        fs.writeFileSync(destinationDir + contracts[idx], cleanSource);
    }

    const dirs = fs.readdirSync(sourceDir)
        .filter(elem => fs.lstatSync(sourceDir + elem).isDirectory());

    for (let idx in dirs) {
//    console.log("Dir " + sourceDir + dirs[idx]);
        preprocessContracts(sourceDir + dirs[idx] + "/", destinationDir, defines);
    }

}

for (var i = 2; i < process.argv.length; i++) {
    preprocessContracts(process.argv[i], 'processed/', {});
}

'use strict'

let rawSemver = process.argv[2];
const type = process.argv[3];

function isValidSemver(version) {
  // Remove leading 'v' if present
  if (version.startsWith('v')) {
    version = version.slice(1);
  }
    const semverRegex = /^([0-9]+)\.([0-9]+)\.([0-9]+)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$/;
    return semverRegex.test(version);
}

if (rawSemver === undefined || rawSemver === null) {
    throw new Error(`Input of first arg is undefined! Input a valid semver.`);
} else if (typeof rawSemver !== 'string') {
    throw new Error(`Input must be a string! Got ${typeof rawSemver}`);
} else if (!isValidSemver(rawSemver)) {
    throw new Error(`Input ${rawSemver} is not a valid semver format`);
}

if (
    type === undefined || 
    type === null ||
    (type !== 'minor' &&  type !== 'patch')
) {
    throw new Error('You must define a type of either "minor" or "patch" as the second argument.');
}

function getSemverPart(semver, part) {
    // Remove leading 'v' if present
    if (semver.startsWith('v')) {
        semver = semver.slice(1);
    }
    const semverRegex = /^([0-9]+)\.([0-9]+)\.([0-9]+)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$/;
    const match = semver.match(semverRegex);
    if (!match) {
        throw new Error('Invalid semver format');
    }
    switch (part) {
        case 'minor':
          return parseInt(match[2], 10);
        case 'patch':
          return parseInt(match[3], 10);
        default:
          throw new Error('Invalid part specified. Use "minor" or "patch".');
    }
}


process.stdout.write(getSemverPart(rawSemver, type).toString());
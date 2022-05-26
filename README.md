# Terascope Base Docker images

[![Build Status](https://app.travis-ci.com/terascope/base-docker-image.svg?branch=master)](https://app.travis-ci.com/terascope/base-docker-image)

This project builds the Terascope base images [used by Teraslice](https://github.com/terascope/teraslice/blob/master/Dockerfile#L1).  Below are the latest docker image tags.

With the terafoundation connectors builtin:

- `terascope/node-base:14.19.3` - 593MB
- `terascope/node-base:16.15.0` - 586MB
- `terascope/node-base:18.2.0`  - 700MB

Without: (this will save the image size by roughly 200MB)

- `terascope/node-base:14.19.3-core` - 367MB
- `terascope/node-base:16.15.0-core` - 360MB
- `terascope/node-base:18.2.0-core`  - 420MB

## Usage

You can test run this locally to get the final image sizes so this `README.md`
can be updated.

```bash
./build-and-push.sh terascope

* BUILDING terascope/node-base:14.19.3...

...

* DONE BUILDING

Do you want to push ? n
Skipping...
```

The publishing is done by TravisCI.

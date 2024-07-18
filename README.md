# Terascope Base Docker images

This project builds the Terascope base images [used by Teraslice](https://github.com/terascope/teraslice/blob/master/Dockerfile#L1).  Below are the latest docker image tags. Tags with only a major version use the latest minor and patch version. Tags with major/minor use the latest patch version. 

With the terafoundation connectors builtin:

- `terascope/node-base:22`
- `terascope/node-base:20`
- `terascope/node-base:18`
- `terascope/node-base:22.*.*`
- `terascope/node-base:20.*.*`
- `terascope/node-base:18.*.*`

Without: (this will save the image size by roughly 200MB)

**_DEPRECATED:_** Core images are no longer built and pushed to docker.hub.  

- `terascope/node-base:22.2.0-core`
- `terascope/node-base:20.11.1-core`
- `terascope/node-base:18.19.1-core`

Check for the latest version tags here:

https://hub.docker.com/r/terascope/node-base/tags

At the moment, manual builds can be done like this (substitute the appropriate
NodeJS version):

```bash
# With connectors
docker build --file Dockerfile --pull \
--build-arg NODE_VERSION=18.19.1 \
--tag terascope/node-base:18.19.1 .

# Without connectors
docker build --file Dockerfile.core --pull \
--build-arg NODE_VERSION=18.19.1 \
--tag terascope/node-base:18.19.1-core .
```

Double check the action output before relying on the above commands.

## Release Workflow

- Docker image builds will happen on any push to any branch other than `master`.
- When a Github release is made, the image will be built and then pushed to
docker hub.

The build and publishing is done by Github Actions.

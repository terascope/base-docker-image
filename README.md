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

- `terascope/node-base:22-core`
- `terascope/node-base:20-core`
- `terascope/node-base:18-core`
- `terascope/node-base:22.*.*-core`
- `terascope/node-base:20.*.*-core`
- `terascope/node-base:18.*.*-core`

Check for the latest version tags here:

https://github.com/terascope/base-docker-image/pkgs/container/node-base

## Pulling node-base image from ghcr.io

Pulling an image can be used with the `docker pull` command:
```
docker pull ghcr.io/terascope/node-base:20
```

A known issue with pulling an image from ghcr is when a token expires, it will pop up with a `denied` error when pulling.

```
Error response from daemon: Head "https://ghcr.io/v2/terascope/node-base/manifests/20": denied: denied
```

To resolve this you can logout of the `ghcr.oi` registry. Signing back in isn't nessesary:
```
docker logout ghcr.io
```

At the moment, manual builds can be done like this (substitute the appropriate
NodeJS version):

```bash
# With connectors
docker build --file Dockerfile --pull \
--build-arg NODE_VERSION=18 \
--tag ghcr.io/terascope/node-base:18 .

# Without connectors
docker build --file Dockerfile.core --pull \
--build-arg NODE_VERSION=18 \
--tag ghcr.io/terascope/node-base:18-core .
```

Double check the action output before relying on the above commands.

## Release Workflow

- Docker image builds will happen on any push to any branch other than `master`.
- The `TERAFOUNDATION_KAFKA_CONNECTOR_VERSION` and `IMAGE_VERSION` build-args are specified in the `.env` file.
- Merging to master will trigger an automated release if the `IMAGE_VERSION` has been increased in the `.env` file.
- When a Github release is made, the image will be built and then pushed to
the github container registry.

**NOTE:** _When making changes to the github workflows, the node matrix array only supports either a major node version or a full specific node version. Ex: [18, 22.4.1]. Adding a major-minor version like "18.19" is not supported as of right now._

### How tags and node versions are released in the workflow

The workflow for the base image tags is closely linked to the Node.js version used in the image. Here's a simple breakdown of how it works:

**Major Version Tag:** The image will either grab the latest available version of a specific major Node.js release from the node alpine image(e.g., Node 18) or it will be pinned to the latest node version that is compatible with the base image. This image is tagged with the major version number (e.g., 18). So in some cases this version will be pinned and not completely up to date with a node release. This tag is always overwritten on release.

**Major-Minor Version Tag:** Next, it will retag and include both the major and minor version numbers (e.g., 18.14). This tag is updated to reflect the latest minor release within the specified major version. This tag will get overwritten in the case of a node-base change or if a new patch is relased for this minor version of node.

**Major-Minor-Patch Version Tag:** Finally, the image will be re-tagged again with the complete version number, including the major, minor, and patch versions (e.g., 18.14.2). This tag points to a specific version of the Node.js release. This image only gets overwritten on a change to the node-base image that isn't node version related.

The build and publishing is done by Github Actions.

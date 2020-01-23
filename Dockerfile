ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine

ENV NPM_CONFIG_LOGLEVEL error
ENV WITH_SASL 0

RUN apk --no-cache add \
    bash \
    tini \
    g++ \
    ca-certificates \
    lz4-dev \
    musl-dev \
    openssl-dev \
    make \
    curl \
    python

RUN node --version
RUN yarn --version
RUN npm --version

RUN mkdir -p /app/source

# Install bunyan
RUN yarn global add \
    --silent \
    --ignore-optional \
    --no-progress \
    --no-emoji \
    --no-cache \
    bunyan

# Install any built-in connectors in /app/
# use npm because there isn't a package.json
WORKDIR /app

RUN apk --no-cache add \
    --virtual .build-deps \
    gcc \
    zlib-dev \
    bsd-compat-headers \
    py-setuptools \
    && npm init --yes > /dev/null \
    && npm install \
    --quiet \
    --no-package-lock \
    --cache /tmp/empty-cache \
    'terafoundation_kafka_connector@~0.5.3' \
    && apk del .build-deps

WORKDIR /app/source

COPY docker-pkg-fix.js  /usr/local/bin/docker-pkg-fix
COPY wait-for-it.sh /usr/local/bin/wait-for-it

ENV NODE_OPTIONS "--max-old-space-size=2048"

# Use tini to handle sigterm and zombie processes
ENTRYPOINT ["/sbin/tini", "--"]

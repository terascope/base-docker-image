ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine

ENV NPM_CONFIG_LOGLEVEL error
ENV WITH_SASL 0

RUN apk --no-cache add \
    bash \
    curl \
    tini \
    g++ \
    ca-certificates \
    lz4-dev \
    musl-dev \
    openssl-dev \
    cyrus-sasl-dev \
    make \
    python

RUN apk add --no-cache \
    --virtual .build-deps \
    gcc \
    zlib-dev \
    libc-dev \
    bsd-compat-headers \
    py-setuptools

RUN node --version
RUN yarn --version
RUN npm --version

RUN mkdir -p /app/source

# Install bunyan
RUN yarn global add \
    --ignore-optional \
    --no-progress \
    --no-emoji \
    --no-cache \
    bunyan

# Install any built-in connectors in /app/
# use npm because there isn't a package.json
WORKDIR /app

RUN yarn init --yes 2> /dev/null \
    && yarn add \
    --ignore-optional \
    --no-progress \
    --no-emoji \
    --no-cache \
    --no-lockfile \
    'terafoundation_kafka_connector@~0.5.3'

RUN apk del .build-deps

WORKDIR /app/source

# verify node-rdkafka is installed right
RUN node -e "require('node-rdkafka')"

COPY docker-pkg-fix.js /usr/local/bin/docker-pkg-fix
COPY wait-for-it.sh /usr/local/bin/wait-for-it

ENV NODE_OPTIONS "--max-old-space-size=2048"

# Use tini to handle sigterm and zombie processes
ENTRYPOINT ["/sbin/tini", "--"]

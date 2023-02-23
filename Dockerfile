ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine

# use an older alpine registry for >=10.19
# because otherwise requiring node-rdkafka breaks
# linux amd64 (like CI)
RUN if [ -z "${NODE_VERSION%%10*}" ]; then \
    sed -i -e 's/v3.11/v3.9/g' /etc/apk/repositories \
    && apk upgrade; \
    fi

RUN apk --no-cache add \
    bash \
    curl \
    tini \
    apk-tools \
    build-base \
    ca-certificates \
    libstdc++ \
    lz4-dev \
    musl-dev \
    ncurses-terminfo \
    libssh2-dev \
    openssl-dev \
    cyrus-sasl-dev \
    zstd-dev \
    python3

RUN apk --no-cache add \
    --virtual .build-deps \
    gcc \
    zlib-dev \
    libc-dev \
    bsd-compat-headers \
    py-setuptools

ENV NPM_CONFIG_LOGLEVEL error
ENV WITH_SASL 0

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

RUN npm init --yes &> /dev/null \
    && npm install \
    --build \
    --no-package-lock \
    --no-optional \
    'terafoundation_kafka_connector@~0.9.0' \
    && npm cache clean --force

RUN apk del .build-deps

WORKDIR /app/source

# verify node-rdkafka is installed right
RUN node --print --eval "require('node-rdkafka')"

COPY docker-pkg-fix.js /usr/local/bin/docker-pkg-fix
COPY wait-for-it.sh /usr/local/bin/wait-for-it

ENV NODE_OPTIONS "--max-old-space-size=2048"

# Use tini to handle sigterm and zombie processes
ENTRYPOINT ["/sbin/tini", "--"]

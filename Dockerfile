ARG NODE_VERSION
FROM node:${NODE_VERSION}-buster

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

RUN yarn init --yes 2> /dev/null \
    && yarn add \
    --ignore-optional \
    --no-progress \
    --no-emoji \
    --no-cache \
    --no-lockfile \
    'terafoundation_kafka_connector@~0.5.3'

WORKDIR /app/source

# verify node-rdkafka is installed right
RUN node -e "require('node-rdkafka')"

COPY docker-pkg-fix.js /usr/local/bin/docker-pkg-fix
COPY wait-for-it.sh /usr/local/bin/wait-for-it

ENV NODE_OPTIONS "--max-old-space-size=2048"

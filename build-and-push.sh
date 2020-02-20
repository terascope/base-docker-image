#!/bin/bash

set -e

prompt() {
    local question="$1"

    if [ "$CI" == "true" ]; then
        echo "* auto-answer yes to $question since this is running in CI"
        return 0
    fi

    while true; do
        read -p "$question " -r yn
        case $yn in
        [Yy]*)
            return 0
            break
            ;;
        [Nn]*)
            echo "Skipping..."
            return 1
            ;;
        *) echo "Please answer yes or no." ;;
        esac
    done
}

docker_build() {
    local registry="$1"
    local version="$2"
    local sub_version="$3"

    local image_tag="${registry}/node-base:$version$sub_version"
    printf '\n* BUILDING %s...\n\n' "$image_tag"
    docker build \
        --build-arg "NODE_VERSION=$version" \
        --no-cache \
        --pull \
        --tag "$image_tag" .
}

docker_push() {
    local registry="$1"
    local version="$2"
    local sub_version="$3"

    local image_tag="${registry}/node-base:$version$sub_version"

    printf '\n* PUSHING %s...\n\n' "$image_tag"
        docker push "$image_tag"
}

main() {
    local registry="${1:-terascope}"

    if [ -z "$registry" ]; then
        echo 'Missing registry as first arg'
        exit 1
    fi

    local sub_version="-1"
    local node_versions=("10.19.0" "12.16.1")
    for node_version in "${node_versions[@]}"; do
        docker_build "$registry" "$node_version" "$sub_version"
    done

    printf '\n* DONE BUILDING \n\n'

    prompt "Do you want to push $image_tag?" || exit 0

    for node_version in "${node_versions[@]}"; do
        docker_push "$registry" "$node_version" "$sub_version"
    done
}

main "$@"

#!/bin/bash

set -e

prompt() {
    local question="$1"

    if [ "$CI" == "true" ] && [ "$TRAVIS_BRANCH" == "master" ]; then
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
    local image_type="$3"
    local version sub_version

    version="$(get_node_version "$2")"
    sub_version="$(get_subversion "$2")"

    local image_tag="${registry}/node-base:$version$sub_version$image_type"
    printf '\n* BUILDING %s...\n\n' "$image_tag"
    local file="Dockerfile"
    if [ "$image_type" == "-core" ]; then
        file="Dockerfile.core"
    fi

    docker build \
        --file "$file" \
        --build-arg "NODE_VERSION=$version" \
        --pull \
        --tag "$image_tag" .
}

docker_push() {
    local registry="$1"
    local image_type="$3"
    local version sub_version

    version="$(get_node_version "$2")"
    sub_version="$(get_subversion "$2")"

    local image_tag="${registry}/node-base:$image_type$version$sub_version"

    printf '\n* PUSHING %s...\n\n' "$image_tag"
        docker push "$image_tag"
}

get_node_version() {
   if [[ "$1" =~ - ]]; then
       local node_version="${1%-*}"
       echo "$node_version"
   else
       echo "$1"
   fi
}

get_subversion() {
   if [[ "$1" =~ - ]]; then
       local sub_version="${1##*-}"
       echo "-$sub_version"
   else
       echo ""
   fi
}

main() {
    local registry="${1:-terascope}"

    if [ -z "$registry" ]; then
        echo 'Missing registry as first arg'
        exit 1
    fi

    local versions=("10.24.0" "12.21.0" "14.16.0")
    for version in "${versions[@]}"; do
        docker_build "$registry" "$version"
        docker_build "$registry" "$version" "-core"
    done

    printf '\n* DONE BUILDING \n\n'

    prompt "Do you want to push $image_tag?" || exit 0

    for version in "${versions[@]}"; do
        docker_push "$registry" "$version"
        docker_push "$registry" "$version" "-core"
    done
}

main "$@"

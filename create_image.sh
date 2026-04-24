#!/bin/bash
set -e

DOCKER_VERSION="29.4.0"
BUILD_NUMBER="0"
LATEST_UBUNTU_VERSION="24.04"

ubuntu_versions=("22.04" "24.04")
ubuntu_names=("jammy" "noble")

build_image() {
    local ubuntu_version=$1
    local ubuntu_name=$2

    echo "Building image for Ubuntu ${ubuntu_version} (${ubuntu_name})"

    docker build \
        --build-arg UBUNTU_VERSION=${ubuntu_version} \
        -t otter-aerospace/ubuntu-dind:${ubuntu_name}-${DOCKER_VERSION} \
        -t otter-aerospace/ubuntu-dind:${ubuntu_name}-${DOCKER_VERSION}-r${BUILD_NUMBER} \
        -t otter-aerospace/ubuntu-dind:${ubuntu_name}-latest \
        -f Dockerfile .

    if [ "${ubuntu_version}" == "${LATEST_UBUNTU_VERSION}" ]; then
        docker tag otter-aerospace/ubuntu-dind:${ubuntu_name}-latest otter-aerospace/ubuntu-dind:latest
    fi
}

build_systemd_image() {
    local ubuntu_version=$1
    local ubuntu_name=$2

    echo "Building image for Ubuntu ${ubuntu_version} (${ubuntu_name}) with systemd"

    docker build \
        --build-arg UBUNTU_VERSION=${ubuntu_version} \
        -t otter-aerospace/ubuntu-dind:${ubuntu_name}-systemd-${DOCKER_VERSION} \
        -t otter-aerospace/ubuntu-dind:${ubuntu_name}-systemd-${DOCKER_VERSION}-r${BUILD_NUMBER} \
        -t otter-aerospace/ubuntu-dind:${ubuntu_name}-systemd-latest \
        -f Dockerfile.systemd .

    if [ "${ubuntu_version}" == "${LATEST_UBUNTU_VERSION}" ]; then
        docker tag otter-aerospace/ubuntu-dind:${ubuntu_name}-systemd-latest otter-aerospace/ubuntu-dind:systemd-latest
    fi
}

for i in "${!ubuntu_versions[@]}"; do
    build_image "${ubuntu_versions[$i]}" "${ubuntu_names[$i]}"
done

for i in "${!ubuntu_versions[@]}"; do
    build_systemd_image "${ubuntu_versions[$i]}" "${ubuntu_names[$i]}"
done

echo "All images built successfully!"

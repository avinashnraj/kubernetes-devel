#!/bin/bash

set -e

echo "Starting installation script for kubelet debug environment..."

# Install dependencies
echo "Installing required packages..."
apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    tar \
    sudo \
    make \
    iproute2 \
    iputils-ping \
    gnupg2 \
    lsb-release \
    ca-certificates \
    jq \
    rsync \
    kmod \
    iptables \
    vim \
    && apt-get clean

# Set up Go environment
echo "Setting up Go environment..."
export GO_VERSION="1.23.0"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

export GOPATH="/go"
export PATH="${GOPATH}/bin:/usr/local/go/bin:/app/kubernetes/_output/bin:${PATH}"
mkdir -p $GOPATH/src $GOPATH/bin && \
    chmod -R 777 $GOPATH

go install golang.org/x/tools/gopls@latest && \
    go install honnef.co/go/tools/cmd/staticcheck@latest

go install github.com/go-delve/delve/cmd/dlv@latest

echo 'export GOPATH="/go"' >> ~/.bashrc
echo 'export PATH="${GOPATH}/bin:/usr/local/go/bin:/app/kubernetes/_output/bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc

# Print completion message
echo "Debug environment setup is complete!"

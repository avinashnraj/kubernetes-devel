# Use an Ubuntu base image
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV VERSION="v1.27.1"
ENV GO_VERSION="1.23.0"
ENV GOPATH="/go"
ENV PATH="$GOPATH/bin:/usr/local/go/bin:/app/kubernetes/_output/bin:$PATH"

# Add and update GPG keys for Ubuntu repositories
RUN apt-get update && apt-get install -y gnupg2 && apt-get clean && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C

# Install required packages
RUN apt-get update && apt-get install -y \
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

# Install CRI-O
ENV CRIO_VERSION="1.26"
ENV OS="xUbuntu_22.04"

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list && \
    echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list && \
    mkdir -p /usr/share/keyrings && \
    curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg || true && \
    curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg || true && \
    apt-get update && \
    apt-get install -y cri-o cri-o-runc cri-tools fuse-overlayfs

# Install nerdctl
RUN wget https://github.com/containerd/nerdctl/releases/download/v2.0.2/nerdctl-2.0.2-linux-amd64.tar.gz && \
    tar -zxf nerdctl-2.0.2-linux-amd64.tar.gz && \
    mv nerdctl /usr/local/bin/ && \
    rm nerdctl-2.0.2-linux-amd64.tar.gz

# Configure CRI-O to use fuse-overlayfs
RUN mkdir -p /etc/crio && \
    sed -i 's/^cgroup_manager = .*/cgroup_manager = "cgroupfs"/' /etc/crio/crio.conf && \
    echo "[crio.storage]" >> /etc/crio/crio.conf && \
    echo "driver = \"overlay\"" >> /etc/crio/crio.conf && \
    echo "[crio.storage.options.overlay]" >> /etc/crio/crio.conf && \
    echo "mount_program = \"/usr/bin/fuse-overlayfs\"" >> /etc/crio/crio.conf && \
    mkdir -p /var/lib/crio /var/run/crio && \
    chmod -R 755 /var/lib/crio /var/run/crio

# Install Go
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Set up Go workspace
RUN mkdir -p $GOPATH/src $GOPATH/bin && \
    chmod -R 777 $GOPATH

# Install `gopls` and `staticcheck`
RUN go install golang.org/x/tools/gopls@latest && \
    go install honnef.co/go/tools/cmd/staticcheck@latest

# Install containerd
RUN wget https://github.com/containerd/containerd/releases/download/v2.0.1/containerd-2.0.1-linux-amd64.tar.gz && \
    tar zxvf containerd-2.0.1-linux-amd64.tar.gz -C /usr/local/ && \
    rm containerd-2.0.1-linux-amd64.tar.gz

# Install runc
RUN wget https://github.com/opencontainers/runc/releases/download/v1.2.3/runc.amd64 && \
    install -m 755 runc.amd64 /usr/local/sbin/runc && \
    rm runc.amd64

# Install etcd
RUN wget https://github.com/etcd-io/etcd/releases/download/v3.5.16/etcd-v3.5.16-linux-amd64.tar.gz && \
    tar xzvf etcd-v3.5.16-linux-amd64.tar.gz && \
    mv etcd-v3.5.16-linux-amd64/etcd /usr/local/bin/etcd && \
    mv etcd-v3.5.16-linux-amd64/etcdctl /usr/local/bin/etcdctl && \
    rm -rf etcd-v3.5.16-linux-amd64.tar.gz etcd-v3.5.16-linux-amd64

# Install CNI plugins
RUN wget https://github.com/containernetworking/plugins/releases/download/v1.6.1/cni-plugins-linux-amd64-v1.6.1.tgz && \
    mkdir -p /opt/cni/bin && \
    tar zxvf cni-plugins-linux-amd64-v1.6.1.tgz -C /opt/cni/bin && \
    rm cni-plugins-linux-amd64-v1.6.1.tgz

# Install CFSSL tools
RUN wget -q --show-progress --https-only --timestamping https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 && \
    chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 && \
    mv cfssl_linux-amd64 /usr/local/bin/cfssl && \
    mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

# Configure containerd
RUN mkdir -p /etc/containerd && \
    containerd config default > /etc/containerd/config.toml
#    sed -i 's/SystemdCgroup = false/SystemdCgroup = false/' /etc/containerd/config.toml && \
#    sed -i 's/\[plugins."io.containerd.internal.v1.tracing.processor"]/\[plugins."io.containerd.internal.v1.tracing.processor"]\n  endpoint = ""/' /etc/containerd/config.toml

# Add CNI network configurations
RUN mkdir -p /etc/cni/net.d && \
    echo '{ \
        "cniVersion": "0.4.0", \
        "name": "bridge", \
        "type": "bridge", \
        "bridge": "cni0", \
        "isGateway": true, \
        "ipMasq": true, \
        "ipam": { \
            "type": "host-local", \
            "ranges": [ \
                [{"subnet": "10.244.0.0/16"}] \
            ], \
            "routes": [ \
                {"dst": "0.0.0.0/0"} \
            ] \
        } \
    }' > /etc/cni/net.d/10-bridge.conf && \
    echo '{ \
        "cniVersion": "0.4.0", \
        "type": "loopback" \
    }' > /etc/cni/net.d/99-loopback.conf

# Install Delve debugger
RUN go install github.com/go-delve/delve/cmd/dlv@latest

# Expose necessary ports (optional)
EXPOSE 80 443

# Set working directory
WORKDIR /app

# Start containerd (default command)
CMD ["/usr/local/bin/containerd"]

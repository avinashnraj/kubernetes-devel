DOCKER_COMPOSE = docker-compose
DOCKER = docker
KIND_CLUSTER_NAME = kube-dev-cluster
KIND_NODE_IMAGE = kindest/kube-node:development
KIND_CONFIG = ./kind-config.yaml
K3D_CLUSTER_NAME = mytest-cluster
K3D_CONFIG = ./k3d-cluster.yaml
METRICS_FOLDER = ./metrics

.PHONY: all-up all-down up down build exec build-up clean kind-create-cluster kind-delete-cluster kind-build \
        kind-list-clusters kind-get-clusters kind-load-image help-config vi-config \
        create-k3d-cluster delete-k3d-cluster exec-k3d-server exec-k3d-agent k3d-list-clusters k3d-kubeconfig

init-submodule:
	@echo "Initializing and updating submodules..."
	git submodule init
	git submodule update --remote
	@echo "Checking out specific tag..."
	cd kubernetes && git fetch --tags && git checkout v1.32.0

# Docker Compose actions
up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down -v

build:
	$(DOCKER) build --platform=linux/amd64 -t ubuntu-node:development .

exec:
	$(DOCKER_COMPOSE) exec -ti node1 bash

build-up:
	$(DOCKER_COMPOSE) up --build -d

clean:
	$(DOCKER_COMPOSE) down --rmi all --volumes --remove-orphans

# Kind cluster actions
kind-create-cluster:
	kind create cluster -n $(KIND_CLUSTER_NAME) --config $(KIND_CONFIG) -v 100000

kind-delete-cluster:
	kind delete cluster --name $(KIND_CLUSTER_NAME)

kind-build:
	kind build node-image --image $(KIND_NODE_IMAGE) $(PWD)/kubernetes/

kind-list-clusters:
	kind get clusters

kind-get-clusters:
	kind get clusters

kind-load-image:
	kind load docker-image $(KIND_NODE_IMAGE)

help-config:
	kind --help

vi-config:
	vi $(KIND_CONFIG)

# K3D cluster actions
create-k3d-cluster:
	k3d cluster create --config $(K3D_CONFIG)

delete-k3d-cluster:
	k3d cluster delete $(K3D_CLUSTER_NAME)

exec-k3d-server:
	docker exec -ti k3d-$(K3D_CLUSTER_NAME)-server-0 sh

exec-k3d-agent:
	docker exec -ti k3d-$(K3D_CLUSTER_NAME)-agent-0 sh

k3d-list-clusters:
	k3d cluster list -o wide

k3d-kubeconfig:
	export KUBECONFIG=$$(k3d kubeconfig write $(K3D_CLUSTER_NAME))

all-up: kind-create-cluster
	cd ${METRICS_FOLDER} && $(MAKE) all k6-test

all-down: kind-delete-cluster clean
	${DOCKER} system prune -f --volumes
	${DOCKER} image prune -f


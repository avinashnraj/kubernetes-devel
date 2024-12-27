DOCKER_COMPOSE = docker-compose
KIND_CLUSTER_NAME = kube-development
KIND_NODE_IMAGE = kindest/node:latest
KIND_CONFIG = ./../kind-config.yaml
K3D_CLUSTER_NAME = mytest-cluster
K3D_CONFIG = ./k3d-cluster.yaml

.PHONY: up down rebuild clean create-cluster delete-cluster build-node-image list-clusters get-clusters load-image help-config vi-config \
        create-k3d-cluster delete-k3d-cluster exec-k3d-server exec-k3d-agent k3d-list-clusters k3d-kubeconfig

up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

rebuild:
	$(DOCKER_COMPOSE) up --build -d

clean:
	$(DOCKER_COMPOSE) down --rmi all --volumes --remove-orphans

create-cluster:
	kind cluster create --config $(KIND_CONFIG)

delete-cluster:
	kind delete cluster $(KIND_CLUSTER_NAME)

build-node-image:
	kind build node-image .

list-clusters:
	kind cluster list

get-clusters:
	kind get clusters

load-image:
	kind load docker-image $(KIND_NODE_IMAGE)

help-config:
	kind --help

vi-config:
	vi $(KIND_CONFIG)

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

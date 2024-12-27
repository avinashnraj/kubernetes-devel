.PHONY: up down rebuild clean

up:
	docker compose up -d

down:
	docker compose down

create-cluster:
	kind create cluster -n kube-development --config ./kind-config.yaml

delete-cluster:
	kind delete clusters kube-development

build-cluster:
	kind build node-image ${PWD}/kubernetes --image kindest/node:development

rebuild:
	docker compose up --build -d

clean:
	docker compose down --rmi all --volumes --remove-orphans


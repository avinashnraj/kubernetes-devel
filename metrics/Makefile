DOCKER_IMAGE = nginx-with-lua-delay
DOCKER_TAG = latest
KUBECTL = kubectl
NAMESPACE = default
K6_SCRIPT = test.js

.PHONY: all build push deploy clean debug k6-test metrics-setup

all: metrics-setup build deploy

build: 
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

push: build
	kind load docker-image $(DOCKER_IMAGE):$(DOCKER_TAG) --name kube-dev-cluster

deploy: push
	$(KUBECTL) apply -f nginx-lua-deployment.yaml

k6-config:
	$(KUBECTL) create configmap k6-script --from-file=$(K6_SCRIPT) --dry-run=client -o yaml | $(KUBECTL) apply -f -

k6-test: k6-config
	$(KUBECTL) apply -f k6-deployment.yaml

debug:
	$(KUBECTL) apply -f debug-pod.yaml

test:
	$(KUBECTL) exec -it $(shell $(KUBECTL) get pod -l app=k6 -o name | head -n 1 | sed 's/pod\///') -- k6 run /scripts/test.js

metrics-setup:
	$(KUBECTL) -n kube-system delete deploy metrics-server || true
	$(KUBECTL) apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
	$(KUBECTL) patch -n kube-system deployment metrics-server --type=json \
	  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm install prometheus-stack prometheus-community/kube-prometheus-stack \
	  --namespace monitoring \
	  --create-namespace
	helm install grafana grafana/grafana \
	  --namespace monitoring \
	  --values values.yaml

clean:
	$(KUBECTL) delete -f nginx-lua-deployment.yaml || true
	$(KUBECTL) delete -f k6-deployment.yaml || true
	$(KUBECTL) delete -f debug-pod.yaml || true
	helm uninstall prometheus-stack -n monitoring || true
	helm uninstall grafana -n monitoring || true
	$(KUBECTL) delete namespace monitoring || true


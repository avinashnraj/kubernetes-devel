# Variables
ISTIO_NAMESPACE := istio-system
ISTIO_VERSION := 1.24.2
ISTIO_RELEASE := istio
HELM_CHART := istio/base
ISTIO_INGRESS_PORT := 80
ISTIO_INGRESS_PORT_SECURE := 443

# Default Target
.PHONY: all
all: install demo-app apply-config

# Install Istio Base Helm Chart
.PHONY: install
install:
	@echo "Adding Istio Helm repository..."
	helm repo add istio https://istio-release.storage.googleapis.com/charts || true
	helm repo update
	@echo "Installing Istio Base..."
	helm upgrade --install istio istio/base \
		--namespace istio-system --create-namespace \
		--set revision=default
	@echo "Installing Istio Control Plane..."
	helm upgrade --install istiod istio/istiod \
		--namespace istio-system \
		--set revision=default
	@echo "Installing Istio Ingress Gateway..."
	helm upgrade --install istio-ingressgateway istio/gateway \
		--namespace istio-system \
		--set revision=default
	@echo "Istio installation complete."

.PHONY: demo-app
demo-app:
	kubectl create namespace demo
	kubectl label namespace demo istio-injection=enabled
	kubectl apply -n demo -f https://raw.githubusercontent.com/istio/istio/release-1.19/samples/httpbin/httpbin.yaml

# Apply Istio Gateway and VirtualService
.PHONY: apply-config
apply-config:
	@echo "Applying Istio Gateway and VirtualService configurations..."
	kubectl apply -f manifests/gateway.yaml
	@echo "Configurations applied."

# Clean up Istio deployment
.PHONY: uninstall
uninstall:
	@echo "Uninstalling Istio and cleaning up resources..."
	kubectl delete namespace demo --ignore-not-found
	helm uninstall $(ISTIO_RELEASE) -n $(ISTIO_NAMESPACE)
	kubectl delete namespace $(ISTIO_NAMESPACE) --ignore-not-found
	@echo "Istio uninstalled and resources cleaned."

# Verify Istio Ingress
.PHONY: verify
verify:
	@echo "Verifying Istio ingress gateway status..."
	kubectl get svc -n $(ISTIO_NAMESPACE) istio-ingressgateway
	@echo "Run 'kubectl describe svc istio-ingressgateway -n $(ISTIO_NAMESPACE)' for more details."

# Restart Istio Ingress Gateway
.PHONY: restart-ingress
restart-ingress:
	@echo "Restarting Istio ingress gateway..."
	kubectl rollout restart deployment/istio-ingressgateway -n $(ISTIO_NAMESPACE)
	@echo "Ingress gateway restarted."

# Port-forward Istio Ingress Gateway
.PHONY: port-forward
port-forward:
	@echo "Port-forwarding Istio ingress gateway..."
	kubectl port-forward svc/istio-ingressgateway -n $(ISTIO_NAMESPACE) $(ISTIO_INGRESS_PORT):80

# Display Istio resources
.PHONY: status
status:
	@echo "Displaying Istio resources..."
	kubectl get all -n $(ISTIO_NAMESPACE)

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  install         - Install Istio using Helm."
	@echo "  apply-config    - Apply Gateway and VirtualService configurations."
	@echo "  uninstall       - Uninstall Istio and clean up resources."
	@echo "  verify          - Verify the status of Istio ingress gateway."
	@echo "  restart-ingress - Restart Istio ingress gateway deployment."
	@echo "  port-forward    - Forward Istio ingress gateway to localhost."
	@echo "  status          - Display Istio resources in the cluster."


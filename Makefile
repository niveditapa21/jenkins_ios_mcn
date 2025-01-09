# Makefile Example

# Define installation steps for Kubernetes
aether-k8s-install:
	@echo "Installing Kubernetes components..."
	# Add actual installation commands for Kubernetes components here
	kubectl apply -f kubernetes/install.yaml
	# Any other commands needed to install Kubernetes components

# Define installation steps for SD-Core
aether-5gc-install:
	@echo "Installing SD-Core components..."
	# Add actual installation commands for SD-Core components here
	kubectl apply -f sd-core/install.yaml
	# Any other commands needed to install SD-Core components

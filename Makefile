
aether-k8s-install:
  @echo "Installing Kubernetes components..."

  kubectl apply -f kubernetes/install.yaml



aether-5gc-install:
  @echo "Installing SD-Core components..."
 
  kubectl apply -f sd-core/install.yaml


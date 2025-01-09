# Example Makefile in the repo
aether-k8s-install:
    kubectl apply -f kubernetes/install.yaml

aether-5gc-install:
    kubectl apply -f sdcore/install.yaml

.PHONY: aether-k8s-install aether-5gc-install

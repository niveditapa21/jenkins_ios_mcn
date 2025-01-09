pipeline {
    agent any
    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'The branch name to check out the code from')
        string(name: 'DOCKER_REPO_URL', defaultValue: 'ghcr.io/your-repo', description: 'The Docker repository URL for authentication')
        string(name: 'K8S_NAMESPACE', defaultValue: 'omec', description: 'The Kubernetes namespace to monitor after installation')
    }
    environment {
        PATH = "${env.PATH}:/usr/bin:$HOME/.local/bin"
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        stage('Prerequisites') {
            steps {
                script {
                    echo "Starting prerequisites setup..."
                }
                sh '''
                    # Remove Conflicting Packages
                    sudo apt-get remove --purge -y containerd
                    sudo apt-get autoremove -y
                    sudo apt-mark unhold containerd || true
                    sudo apt-get update -y
                '''
                sh '''
                    # Install Docker, Make, and other required dependencies
                    if ! command -v docker &> /dev/null; then
                        echo "Docker not found. Installing Docker..."
                        curl -fsSL https://get.docker.com | sudo sh
                    fi
                    sudo apt-get install -y containerd.io git curl net-tools pipx python3-venv sshpass netplan.io iptables jq sed
                    pipx install --include-deps ansible || true
                    pipx ensurepath
                '''
                sh '''
                    # Validate Installations
                    docker --version
                    echo "Prerequisites setup complete."
                '''
            }
        }
        stage('Build') {
            steps {
                script {
                    echo "Starting the build process..."
                }
                sh '''
                    # Checkout the specified branch
                    git checkout ${BRANCH_NAME}
                    # Example build step
                    echo "Building project from branch: ${BRANCH_NAME}"
                    # Add actual build commands here
                '''
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo "Starting deployment process..."
                }
                withCredentials([usernamePassword(credentialsId: '08fde406-6aa2-4233-b7a7-3510b1f1b951', usernameVariable: 'GHCRUSER', passwordVariable: 'GHCRPASS')]) {
                    sh '''
                        # Docker Authentication for GHCR
                        echo "$GHCRPASS" | sudo docker login ${DOCKER_REPO_URL} -u "$GHCRUSER" --password-stdin
                    '''
                }
                sh '''
                    # Example deployment commands
                    echo "Deploying components to Kubernetes..."
                    # Add actual deployment commands here
                '''
            }
        }
        stage('Installation') {
            steps {
                script {
                    echo "Starting installation process..."
                }
                sh '''
                    # Apply Kubernetes configurations for Aether components
                    if [ ! -f aether-k8s-install.yaml ]; then
                        echo "aether-k8s-install.yaml not found, creating one..."
                        cat <<EOL > aether-k8s-install.yaml
apiVersion: v1
kind: Pod
metadata:
  name: aether-k8s-example
  namespace: ${K8S_NAMESPACE}
spec:
  containers:
  - name: example-container
    image: busybox
    command: ["sleep", "3600"]
EOL
                    fi
                    echo "Applying Kubernetes configuration for Aether Kubernetes components..."
                    kubectl apply -f aether-k8s-install.yaml

                    # Apply Kubernetes configurations for SD-Core
                    if [ ! -f aether-5gc-install.yaml ]; then
                        echo "aether-5gc-install.yaml not found, creating one..."
                        cat <<EOL > aether-5gc-install.yaml
apiVersion: v1
kind: Service
metadata:
  name: aether-5gc-service
  namespace: ${K8S_NAMESPACE}
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  selector:
    app: aether-5gc
EOL
                    fi
                    echo "Applying Kubernetes configuration for Aether 5GC components..."
                    kubectl apply -f aether-5gc-install.yaml

                    # Verify installation
                    echo "Fetching Kubernetes Pods in namespace: ${K8S_NAMESPACE}..."
                    kubectl get pods -n ${K8S_NAMESPACE}
                '''
            }
        }
    }
    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}

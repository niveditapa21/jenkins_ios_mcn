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
                    # Install Docker and other required dependencies
                    if ! command -v docker &> /dev/null; then
                        echo "Docker not found. Installing Docker..."
                        curl -fsSL https://get.docker.com | sudo sh
                    else
                        echo "Docker already installed."
                    fi
                    sudo apt-get install -y containerd.io git curl make net-tools pipx python3-venv sshpass netplan.io iptables jq sed
                    pipx install --include-deps ansible || true
                    pipx ensurepath
                '''
                sh '''
                    # Validate Installations
                    docker --version
                    kubectl version --client
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
                    # Install Kubernetes components directly
                    echo "Installing Kubernetes components..."
                    kubectl create deployment my-deployment --image=nginx  # Example Kubernetes installation
                    kubectl expose deployment my-deployment --type=LoadBalancer --port=8080  # Expose service for testing
                    
                    # Wait for a minute to ensure deployment is ready (you can use kubectl wait for more sophisticated checks)
                    sleep 60

                    # Install SD-Core components directly
                    echo "Installing SD-Core components..."
                    kubectl apply -f https://example.com/sd-core-deployment.yaml  # Example SD-Core YAML URL

                    # Verify if the pods are running
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

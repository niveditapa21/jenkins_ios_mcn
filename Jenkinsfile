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
                    if ! command -v make &> /dev/null; then
                        echo "Make not found. Installing Make..."
                        sudo apt-get install -y make
                    fi
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
                    make --version
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
                    # Check if the Makefile exists
                    if [ ! -f Makefile ]; then
                        echo "Makefile not found, creating one..."

                        # Create a Makefile with proper formatting
                        printf "aether-k8s-install:\\n\\t# Add actual installation commands for Kubernetes components\\n\\techo \\"Installing Aether Kubernetes components...\\"\\n\\tkubectl apply -f aether-k8s-install.yaml\\n\\n" > Makefile

                        printf "aether-5gc-install:\\n\\t# Add actual installation commands for SD-Core\\n\\techo \\"Installing Aether 5GC components...\\"\\n\\tkubectl apply -f aether-5gc-install.yaml\\n" >> Makefile
                    fi

                    # Print the Makefile for debugging purposes
                    echo "Generated Makefile contents:"
                    cat Makefile

                    # List all available targets in the Makefile
                    make -n

                    # Run the installation with the make target
                    make aether-k8s-install
                '''
                sh '''
                    # Install SD-Core using make
                    make aether-5gc-install
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

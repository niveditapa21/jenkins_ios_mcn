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
        stage('Remove Conflicting Packages & installing Prerequisites') {
            steps {
                script {
                    echo "remove conflicting packages & prerequisites setup..."
                }
                sh '''
                    
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
                withCredentials([usernamePassword(credentialsId: 'a5e604ba-def8-4ab1-9192-7fd6d0ca7c66', usernameVariable: 'GHCRUSER', passwordVariable: 'GHCRPASS')]) {
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
                    # Install Kubernetes Components
                    sudo apt install make
                    sudo apt install sshpass python3-venv pipx make git
                    pipx install --include-deps ansible
                    pipx ensurepath
                  
                    ansible --version
                    rm -rf aether-onramp

                    git clone --recursive https://github.com/opennetworkinglab/aether-onramp.git
                    cd aether-onramp
                    make aether-k8s-install
                '''
                sh '''
                    # Install SD-Core
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

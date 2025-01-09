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
                sh '''#!/bin/bash
                    # Remove Conflicting Packages
                    sudo apt-get remove --purge -y containerd
                    sudo apt-get autoremove -y
                    sudo apt-mark unhold containerd || true
                    sudo apt-get update -y
                '''
                sh '''#!/bin/bash
                    # Install Required Tools and Dependencies
                    if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
                        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                    else
                        echo "Docker keyring already exists. Skipping creation."
                    fi
                    sudo chmod a+r /usr/share/keyrings/docker-archive-keyring.gpg
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                    sudo apt-get update -y
                    sudo apt-get install -y containerd.io git curl make net-tools pipx python3-venv sshpass netplan.io iptables jq sed
                    pipx install --include-deps ansible || true
                    pipx ensurepath
                '''
                sh '''#!/bin/bash
                    # Validate Installations
                    make --version
                    echo "Prerequisites setup complete."
                '''
            }
        }
        stage('Build') {
            steps {
                script {
                    echo "Starting the build process..."
                }
                sh '''#!/bin/bash
                    # Checkout the specified branch
                    git checkout ${params.BRANCH_NAME}
                    # Example build step
                    echo "Building project from branch: ${params.BRANCH_NAME}"
                    # Add actual build commands here
                '''
            }
        }
        stage('Deploy') {
            steps {
                script {
                    echo "Starting deployment process..."
                }
                withCredentials([usernamePassword(credentialsId: 'ghcr-credentials', usernameVariable: 'GHCRUSER', passwordVariable: 'GHCRPASS')]) {
                    sh '''#!/bin/bash
                        # Docker Authentication for GHCR
                        echo "$GHCRPASS" | sudo docker login ${params.DOCKER_REPO_URL} -u "$GHCRUSER" --password-stdin
                    '''
                }
                sh '''#!/bin/bash
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
                sh '''#!/bin/bash
                    # Install Kubernetes Components
                    make aether-k8s-install
                '''
                sh '''#!/bin/bash
                    # Install SD-Core
                    make aether-5gc-install
                    kubectl get pods -n ${params.K8S_NAMESPACE}
                '''
            }
        }
    }
    post {
        success {
            echo "Pipeline completed successfully!"
            // Add notifications (e.g., email or Slack) if needed
        }
        failure {
            echo "Pipeline failed!"
            // Add failure notifications if needed
        }
    }
}

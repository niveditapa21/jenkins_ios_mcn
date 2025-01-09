pipeline {
    agent any

    parameters {
        booleanParam(name: 'RUN_INSTALL', defaultValue: true, description: 'Run Installation')
        booleanParam(name: 'RUN_BUILD', defaultValue: true, description: 'Run Build')
        booleanParam(name: 'RUN_DEPLOY', defaultValue: true, description: 'Run Deploy')
    }

    stages {
        stage('Install Prerequisites') {
            when {
                expression { return params.RUN_INSTALL }
            }
            steps {
                sh '''
                echo "Installing prerequisites..."
                sudo apt-get remove --purge -y containerd
                sudo apt-get autoremove -y
                sudo apt-mark unhold containerd || true
                sudo apt-get update -y
                sudo apt-get install -y containerd.io git curl make net-tools pipx python3-venv sshpass netplan.io iptables jq sed
                pipx install --include-deps ansible || true
                pipx ensurepath
                make --version
                '''
            }
        }

        stage('Build') {
            when {
                expression { return params.RUN_BUILD }
            }
            steps {
                sh '''
                echo "Running build simulation..."
                mkdir -p build
                cd build
                touch main.o utils.o program.bin
                echo "Build files created"
                ls -la
                cd .. 
                rm -rf build
                echo "Build simulation completed!"
                '''
            }
        }

        stage('Deploy') {
            when {
                expression { return params.RUN_DEPLOY }
            }
            steps {
                sh '''
                echo "Deploying to Kubernetes..."
                make aether-k8s-install
                make aether-5gc-install
                kubectl get pods -n omec
                '''
            }
        }
    }
}

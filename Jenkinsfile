pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['production', 'dr'],
            description: 'Select the environment to deploy'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action to perform'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto approve terraform apply/destroy'
        )
    }
    
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = '.terraformrc'
        PATH = "$PATH:$HOME/.local/bin"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Deploying to environment: ${params.ENVIRONMENT}"
                echo "Terraform action: ${params.ACTION}"
            }
        }
        
stage('Setup Terraform') {
    steps {
        script {
            sh '''
                REQUIRED_VERSION="1.5.7"
                
                # Function to install Terraform
                install_terraform() {
                    echo "Installing Terraform ${REQUIRED_VERSION}..."
                    wget https://releases.hashicorp.com/terraform/${REQUIRED_VERSION}/terraform_${REQUIRED_VERSION}_linux_amd64.zip
                    unzip terraform_${REQUIRED_VERSION}_linux_amd64.zip
                    chmod +x terraform
                    mkdir -p ~/.local/bin
                    mv terraform ~/.local/bin/
                    rm terraform_${REQUIRED_VERSION}_linux_amd64.zip
                    echo "Terraform ${REQUIRED_VERSION} installed successfully to ~/.local/bin/"
                }

                # Check if Terraform is installed
                if ! command -v terraform &> /dev/null; then
                    install_terraform
                else
                    INSTALLED_VERSION=$(terraform version -json | jq -r '.terraform_version')
                    echo "Installed Terraform version: $INSTALLED_VERSION"
                    if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
                        echo "Updating Terraform to ${REQUIRED_VERSION}..."
                        install_terraform
                    else
                        echo "Terraform is up-to-date."
                    fi
                fi

                export PATH="$HOME/.local/bin:$PATH"
                terraform version
            '''
        }
    }
}

        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(credentialsId: 'ARM_CLIENT_ID_pm', variable: 'ARM_CLIENT_ID_pm'),
                    string(credentialsId: 'ARM_CLIENT_SECRET_pm', variable: 'ARM_CLIENT_SECRET_pm'),
                    string(credentialsId: 'ARM_TENANT_ID_pm', variable: 'ARM_TENANT_ID_pm'),
                    string(credentialsId: 'ARM_SUBSCRIPTION_ID_pm', variable: 'ARM_SUBSCRIPTION_ID_pm')
                ]) {
                    sh '''
                        export PATH="$HOME/.local/bin:$PATH"
                        echo "Initializing Terraform..."
                        terraform init -upgrade -input=false
                    '''
                }
            }
        }
        
       stage('Terraform Validate') {
    	steps {
        withCredentials([
            string(credentialsId: 'ARM_CLIENT_ID_pm', variable: 'ARM_CLIENT_ID_pm'),
            string(credentialsId: 'ARM_CLIENT_SECRET_pm', variable: 'ARM_CLIENT_SECRET_pm'),
            string(credentialsId: 'ARM_TENANT_ID_pm', variable: 'ARM_TENANT_ID_pm'),
            string(credentialsId: 'ARM_SUBSCRIPTION_ID_pm', variable: 'ARM_SUBSCRIPTION_ID_pm')
        ]) {
            sh '''
                export PATH="$HOME/.local/bin:$PATH"
                echo "Formatting and validating Terraform configuration..."
                terraform fmt
                terraform validate
            '''
        }
    }
}

        
        stage('Terraform Plan') {
            when {
                anyOf {
                    expression { params.ACTION == 'plan' }
                    expression { params.ACTION == 'apply' }
                }
            }
            steps {
                withCredentials([
                    string(credentialsId: 'ARM_CLIENT_ID_pm', variable: 'ARM_CLIENT_ID_pm'),
                    string(credentialsId: 'ARM_CLIENT_SECRET_pm', variable: 'ARM_CLIENT_SECRET_pm'),
                    string(credentialsId: 'ARM_TENANT_ID_pm', variable: 'ARM_TENANT_ID_pm'),
                    string(credentialsId: 'ARM_SUBSCRIPTION_ID_pm', variable: 'ARM_SUBSCRIPTION_ID_pm')
                ]) {
                    script {
                        sh """
                            export PATH="\$HOME/.local/bin:\$PATH"
                            echo "Planning Terraform deployment for ${params.ENVIRONMENT}..."
                            terraform plan -var="environment=${params.ENVIRONMENT}" -out=tfplan-${params.ENVIRONMENT}
                        """
                        
                        // Archive the plan file
                        archiveArtifacts artifacts: "tfplan-${params.ENVIRONMENT}", fingerprint: true
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    if (params.AUTO_APPROVE) {
                        withCredentials([
                            string(credentialsId: 'ARM_CLIENT_ID_pm', variable: 'ARM_CLIENT_ID_pm'),
                            string(credentialsId: 'ARM_CLIENT_SECRET_pm', variable: 'ARM_CLIENT_SECRET_pm'),
                            string(credentialsId: 'ARM_TENANT_ID_pm', variable: 'ARM_TENANT_ID_pm'),
                            string(credentialsId: 'ARM_SUBSCRIPTION_ID_pm', variable: 'ARM_SUBSCRIPTION_ID_pm')
                        ]) {
                            sh """
                                export PATH="\$HOME/.local/bin:\$PATH"
                                echo "Applying Terraform configuration for ${params.ENVIRONMENT}..."
                                terraform apply -auto-approve -var="environment=${params.ENVIRONMENT}"
                            """
                        }
                    } else {
                        input message: "Approve Terraform Apply for ${params.ENVIRONMENT}?", ok: 'Apply'
                        withCredentials([
                            string(credentialsId: 'ARM_CLIENT_ID_pm', variable: 'ARM_CLIENT_ID_pm'),
                            string(credentialsId: 'ARM_CLIENT_SECRET_pm', variable: 'ARM_CLIENT_SECRET_pm'),
                            string(credentialsId: 'ARM_TENANT_ID_pm', variable: 'ARM_TENANT_ID_pm'),
                            string(credentialsId: 'ARM_SUBSCRIPTION_ID_pm', variable: 'ARM_SUBSCRIPTION_ID_pm')
                        ]) {
                            sh """
                                export PATH="\$HOME/.local/bin:\$PATH"
                                echo "Applying Terraform configuration for ${params.ENVIRONMENT}..."
                                terraform apply -auto-approve -var="environment=${params.ENVIRONMENT}"
                            """
                        }
                    }
                }
            }
        }
        
        stage('Terraform Destroy') {
    when {
        expression { params.ACTION == 'destroy' }
    }
    steps {
        script {
            input message: "Are you sure you want to destroy ${params.ENVIRONMENT} infrastructure?", ok: 'Destroy'
            withCredentials([
                string(credentialsId: 'ARM_CLIENT_ID_pm', variable: 'ARM_CLIENT_ID_pm'),
                string(credentialsId: 'ARM_CLIENT_SECRET_pm', variable: 'ARM_CLIENT_SECRET_pm'),
                string(credentialsId: 'ARM_TENANT_ID_pm', variable: 'ARM_TENANT_ID_pm'),
                string(credentialsId: 'ARM_SUBSCRIPTION_ID_pm', variable: 'ARM_SUBSCRIPTION_ID_pm')
            ]) {
                sh """
                    export PATH="\$HOME/.local/bin:\$PATH"
                    echo "Refreshing state to match Azure reality..."
                    terraform apply -refresh-only -auto-approve -var="environment=${params.ENVIRONMENT}"
                    echo "Current resources in state:"
                    terraform state list
                    echo "Destroying Terraform infrastructure for ${params.ENVIRONMENT}..."
                    terraform destroy -auto-approve -var="environment=${params.ENVIRONMENT}"
                """
            }
        }
    }
}

        
        stage('Output Results') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([
                    string(credentialsId: 'ARM_CLIENT_ID_pm', variable: 'ARM_CLIENT_ID_pm'),
                    string(credentialsId: 'ARM_CLIENT_SECRET_pm', variable: 'ARM_CLIENT_SECRET_pm'),
                    string(credentialsId: 'ARM_TENANT_ID_pm', variable: 'ARM_TENANT_ID_pm'),
                    string(credentialsId: 'ARM_SUBSCRIPTION_ID_pm', variable: 'ARM_SUBSCRIPTION_ID_pm')
                ]) {
                    sh '''
                        export PATH="$HOME/.local/bin:$PATH"
                        echo "=== Terraform Outputs ==="
                        terraform output
                        echo "=== Infrastructure Summary ==="
                        terraform show -no-color
                    '''
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo "Terraform ${params.ACTION} completed successfully for ${params.ENVIRONMENT}!"
        }
        failure {
            echo "Terraform ${params.ACTION} failed for ${params.ENVIRONMENT}!"
        }
    }
}

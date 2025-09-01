pipeline {
    agent any
    environment {
        PATH = "$PATH:$HOME/.local/bin"
    }
    parameters {
        choice(name: 'ENV', choices: ['production','dr'], description: 'Select environment')
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/priyanshumishracs/BEE.git', branch: 'main'
            }
        }
        stage('Terraform Operations') {
            steps {
                withCredentials([
                    string(credentialsId: 'ARM_CLIENT_ID_pm', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'ARM_CLIENT_SECRET_pm', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'ARM_TENANT_ID_pm', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'ARM_SUBSCRIPTION_ID_pm', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {
                    sh '''
                        # Set environment variables for all Terraform operations
                        export ARM_CLIENT_ID=$ARM_CLIENT_ID
                        export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
                        export ARM_TENANT_ID=$ARM_TENANT_ID
                        export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
                        
                        # Terraform Init
                        echo "=== Terraform Init ==="
                        terraform workspace select ${ENV} || terraform workspace new ${ENV}
                        terraform init -input=false
                        
                        # Terraform Plan
                        echo "=== Terraform Plan ==="
                        terraform plan -var="environment=${ENV}" -out=tfplan -input=false
                        
                        # Terraform Apply
                        echo "=== Terraform Apply ==="
                        terraform apply -input=false -auto-approve tfplan
                        
                        # Terraform Output
                        echo "=== Terraform Output ==="
                        terraform output
                    '''
                }
            }
        }
    }
    post {
        always {
            // Clean up plan file
            sh 'rm -f tfplan || true'
        }
    }
}

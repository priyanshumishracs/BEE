pipeline {
    agent any

    environment {
        PATH = "$PATH:$HOME/.local/bin"
    }

    parameters {
        choice(name: 'ENV', choices: ['prod','dr'], description: 'Select environment')
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/priyanshumishracs/BEE.git', branch: 'main'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(credentialsId: 'ARM_CLIENT_ID_pm', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'ARM_CLIENT_SECRET_pm', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'ARM_TENANT_ID_pm', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'ARM_SUBSCRIPTION_ID_pm', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {
                    sh '''
                        export ARM_CLIENT_ID=$ARM_CLIENT_ID
                        export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
                        export ARM_TENANT_ID=$ARM_TENANT_ID
                        export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID

                        terraform workspace select ${ENV} || terraform workspace new ${ENV}
                        terraform init -input=false
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    terraform plan -var="environment=${ENV}" -out=tfplan -input=false
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    terraform apply -input=false -auto-approve tfplan
                '''
            }
        }

        stage('Output') {
            steps {
                sh 'terraform output'
            }
        }
    }
}

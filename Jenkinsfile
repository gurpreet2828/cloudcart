pipeline {
  agent any

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Deployment') {
      steps {
        // Use your AWS credentials stored in Jenkins (type: AWS Credentials)
        withAWS(credentials: 'aws-credentials', region: 'us-east-1') {
          // Initialize Terraform
          sh 'terraform init'

          // Plan Terraform changes and save to file
          sh 'terraform plan -out=tfplan'

          // Wait for manual approval before applying changes
          input message: 'Approve Terraform Apply?'

          // Apply the Terraform plan
          sh 'terraform apply tfplan'
        }
      }
    }
  }
}

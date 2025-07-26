pipeline {
  agent any

  stages {
    stage('Terraform') {
      steps {
        withCredentials([
          string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
          string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
        ]) {
          sh '''
            terraform init
            terraform plan -out=tfplan
          '''
          input message: 'Approve deployment?'
          sh 'terraform apply tfplan'
        }
      }
    }
  }
}

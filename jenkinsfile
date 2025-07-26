pipeline {
  agent any

  environment {
    AWS_ACCESS_KEY_ID     = credentials('aws-credentials')
    AWS_SECRET_ACCESS_KEY = credentials('aws-credentials')
  }

  stages {
    stage('Checkout Code') {
      steps {
        git url: 'https://github.com/gurpreet2828/cloudcart.git'
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -out=tfplan'
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: 'Approve deployment?'
        sh 'terraform apply tfplan'
      }
    }
  }
}

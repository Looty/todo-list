pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_access_key')
        REPO_URL = "498047829710.dkr.ecr.eu-central-1.amazonaws.com"
        REPO_NAME_APP = "$REPO_URL/todolistapp:latest"
        REPO_NAME_NGINX = "$REPO_URL/todolistnginx:latest"
    }

    options {
        timestamps()
        timeout(time:15, unit:'MINUTES')
        buildDiscarder(logRotator(
            numToKeepStr: '8',
            daysToKeepStr: '10',
            artifactNumToKeepStr: '30'))
    }

    stages {
        stage('build') {
            steps {
                sh "echo ==== BUILD STAGE ====="
                sh "docker build -t $REPO_NAME_APP -f Dockerfile.backend ."
                sh "docker build -t $REPO_NAME_NGINX -f Dockerfile.frontend ."
            }
        }

        stage('E2E') {
            steps {
                sh "echo ==== E2E STAGE ====="
                sh "docker-compose up -d"
                sh "curl nginx:80"
            }
        }

        stage ('publish') {
            steps {
                sh "echo ==== PUBLISH STAGE ====="
            }
        }

        stage('deploy') {
            // when {
            //     changelog '.*#test*.'
            // }
            steps {
                script {
                    sh "echo ==== DEPLOY STAGE ====="
                    
                }
            }
        }

        stage ("e2e") {
            // when {
            //     changelog '.*#test*.'
            // }
            steps {
                sh "echo ==== E2E STAGE ====="
                
            }
        }
    }

    post {
        failure {
            sh "echo ==== DESTROY ====="
            
        }
    }
}
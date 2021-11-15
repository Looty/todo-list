pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_access_key')
        REPO_URL = "498047829710.dkr.ecr.eu-central-1.amazonaws.com"
        REPO_NAME_APP = "$REPO_URL/todolistapp:latest"
        REPO_NAME_NGINX = "$REPO_URL/todolistnginx:latest"
        DOCKER_NETWORK = ""
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
                sh "docker build -t $REPO_NAME_NGINX -f ./nginx/Dockerfile.frontend ."
            }
        }

        stage('E2E') {
            steps {
                script {
                    sh "echo ==== E2E STAGE ====="
                    sh "docker-compose up -d --build"
                    DOCKER_NETWORK = sh(script: 'echo $(docker network ls --no-trunc | grep "todo-list" | cut -d " " -f 4)', returnStdout: true).trim()
                    sh "docker run --network $DOCKER_NETWORK --rm curlimages/curl:7.80.0 nginx:80"
                    sh "docker-compose down -v"
                }
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
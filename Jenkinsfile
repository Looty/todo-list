pipeline {
    agent any

    environment {
        TEST = "OK"
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
            }
        }

        stage('run') {
            steps {
                sh "echo ==== RUN STAGE ====="
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
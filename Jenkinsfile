pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_access_key')
        REPO_URL = "498047829710.dkr.ecr.eu-central-1.amazonaws.com"
        LATEST_RELEASE_VERSION = "latest"
        REPO_NAME_APP = "$REPO_URL/todolistapp:$LATEST_RELEASE_VERSION"
        REPO_NAME_NGINX = "$REPO_URL/todolistnginx:$LATEST_RELEASE_VERSION"
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
        stage('pull') {
            when {
                branch 'release/*'
            }
            steps {
                script {
                    sshagent(credentials: ['ssh-github']) {
                        sh "echo BRANCH_NAME=${env.BRANCH_NAME}"
                        sh "./version-script.sh ${env.BRANCH_NAME}"
                        LATEST_RELEASE_VERSION = sh(script: 'echo $(cat ./new_version.txt)', returnStdout: true).trim()
                        sh "git clean -f"
                    }
                }
            }
        }
        stage('build') {
            steps {
                script {
                    sh "echo ==== BUILD STAGE ====="
                    REPO_NAME_APP = "$REPO_URL/todolistapp:$LATEST_RELEASE_VERSION"
                    REPO_NAME_NGINX = "$REPO_URL/todolistnginx:$LATEST_RELEASE_VERSION"
                    sh "docker build -t $REPO_NAME_APP -f Dockerfile.backend ."
                    sh "docker build -t $REPO_NAME_NGINX -f ./nginx/Dockerfile.frontend ."
                }
            }
        }

        stage('E2E') {
            steps {
                script {
                    sh "echo ==== E2E STAGE ====="
                    sh """sed -i "s/x.x/$LATEST_RELEASE_VERSION/g" .env"""
                    sh "docker-compose up -d --build"
                    DOCKER_NETWORK = sh(script: 'echo $(docker network ls --no-trunc | grep "todo-list" | tail -n 1 | cut -d " " -f 4)', returnStdout: true).trim()
                    sh "docker run --network $DOCKER_NETWORK --rm curlimages/curl:7.80.0 nginx:80"
                    sh "docker-compose down -v"
                }
            }
        }

        stage ('tagging') {
            when {
                branch 'release/*'
            }
            steps {
                script {
                    sshagent(credentials: ['ssh-github']) {
                        sh "echo ==== TAGGING STAGE ====="
                        sh "git tag $LATEST_RELEASE_VERSION"
                        sh "git push origin ${env.BRANCH_NAME} tag $LATEST_RELEASE_VERSION"
                    }
                }
            }
        }

        stage ('publish') {
            steps {
                script {
                    sh "echo ==== PUBLISH STAGE ====="
                    sh "echo Publishing the image to the ECR..."
                    sh "aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID"
                    sh "aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY"
                    sh "aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $REPO_URL"
                    sh "docker push $REPO_NAME_APP"
                    sh "docker push $REPO_NAME_NGINX"
                }
            }
        }

        stage('deploy') {
            when {
                branch 'release/*'
            }
            steps {
                script {
                    sshagent(credentials: ['ssh-github']) {
                        sh """
                            echo ==== DEPLOY TO ARGOCD STAGE =====
                            git clone git@github.com:Looty/todo-list-charts.git
                            cd todo-list-charts/
                            echo $PWD
                            pushd todo  
                        """   
                            
                        def filename = 'values.yaml'
                        def data = readYaml file: filename
                        data.image.tag = ${LATEST_RELEASE_VERSION}

                        sh "rm $filename"
                            writeYaml file: filename, data: data

                        sh """
                            popd
                            pushd nginx
                        """

                        filename = 'values.yaml'
                        data = readYaml file: filename
                        data.image.tag = ${LATEST_RELEASE_VERSION}

                        sh "rm $filename"
                            writeYaml file: filename, data: data

                        sh """
                            popd
                            git add .
                            git commit -am "Updated app+nginx image tag to ${LATEST_RELEASE_VERSION}"
                            git push origin main
                        """
                    }
                }
            }
        }
    }

    post {
        failure {
            sh "echo ==== DESTROY ====="
        }
    }
}
#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@lesson-100', retriever: modernSCM(
    [$class: 'GitSCMSource',
    remote: 'https://github.com/yanaddn/jenkins-shared-library.git',
    credentialsId: 'github-creds'
    ]
)

pipeline {
    agent any
    tools {
        maven 'maven3.6'
    }
    stages {
        stage("increment app version") {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "yanadidun/java-maven-app:${version}-${BUILD_NUMBER}"
                }
            }
        }
        stage('build app') {
            steps {
                script {
                    echo 'building app jar...'
                    buildJar()
                }
            }
        }
        stage('build and push image') {
            steps {
                script {
                    echo 'building docker image...'
                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        }

        stage('provision server') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins-aws-access-key-id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
                TF_VAR_env_prefix = 'test'
            }
            steps {
                script {
                    echo 'provisioning server with terraform...'
                    dir('terraform') {
                        sh "terraform init && terraform apply -auto-approve"
                        EC2_PUBLIC_IP = sh (
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        stage('deploy') {
            environment {
                DOCKER_CREDS = credentials('docker-creds')
            }
            steps {
                script {
                    sleep(time:90, unit: "SECONDS") // wait for EC2 instance to initialize

                    echo 'deploying docker image to EC2...'
                    def shellCmd = "bash ./server-cmds.sh ${env.IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                    def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"
                    
                    sshagent(['ec2-server-key']) {
                        sh "scp server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }
                }
            }
        }
        /*
        stage('commit version update') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        // git config for the first time run
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "jenkins"'

                        sh 'git remote set-url origin https://${USER}:${PASS}@github.com/yanaddn/java-maven-app.git'
                        sh 'git add .'
                        sh 'git commit -m "ci: version bump [ci skip]"'
                        sh 'git push origin HEAD:aws-docker-compose'
                    }
                }
            }
        }
        */
    }   
}

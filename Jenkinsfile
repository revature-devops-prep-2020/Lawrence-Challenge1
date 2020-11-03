def repoId = "reblank/challenge1:${currentBuild.number}"

pipeline {
    agent none
    stages {
        stage('build & verify')
        {
            agent {
                docker { 
                    image 'maven'
                    args '-v $HOME/.m2:/root/.m2' }
            }
            stages{
                stage('build') {
                    steps {
                        git url: 'https://github.com/re-blank/Jank8-sSampleWebProject'
                        sh 'mvn package'
                    }
                }
                stage('sonarqube') {
                    steps { 
                        withSonarQubeEnv('SonarCloud')
                        {
                            sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar'
                        }
                    }
                }
            }   
        }
        
        stage('Docker')
        {
            agent {
                docker { image 'docker' }
            }
            stages {
                stage('docker build') {   
                    steps {
                        script {
                            image = docker.build(repoId)
                        }
                        
                        /*script {
                            docker.withTool('docker') {
                                repoId = "reblank/challenge1"
                                image = docker.build(repoId)
                                docker.withRegistry("", "DOCKER_HUB_TOKEN") {
                                    image.push()
                                }
                            }
                        }*/
                    }
                }
                stage('docker push') {
                    steps {
                        script {
                            image = docker.image(repoId)
                            docker.withRegistry("", "docker_hub_credentials") {
                                image.push()
                            }
                        }
                    }
                }
            }
            
        }
        
        stage('app deploy') {
            agent {
                docker { image 'reblank/kubectl_agent' }
            }
            steps
            {
                git url: 'https://github.com/re-blank/Jank8-sSampleWebProject'
                withKubeConfig([credentialsId: 'kube-sa', serverUrl: 'https://kubernetes.docker.internal:6443']) {
                    sh 'kubectl apply -f kubernetes'
                }
            }
            
        }
    }
}
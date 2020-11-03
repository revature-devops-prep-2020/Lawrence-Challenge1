def repoId = "reblank/challenge1:${currentBuild.number}"
def kubeMaster = "https://4F8B79F4A1D26B81BA998C318A3E06C2.gr7.us-east-1.eks.amazonaws.com"

pipeline {
    agent none
    stages {
        stage('build & verify')
        {
            agent {
                docker { 
                    image 'maven'
                    args '-v $HOME/.m2:/root/.m2 --net=host' }
            }
            stages{
                stage('Test') {
                    steps {
                        git url: 'https://github.com/re-blank/Jank8-sSampleWebProject'
                        sh 'mvn test'
                    }
                    post
                    {
                        success{
                            slackSend(color: '#00FF00', message: "${currentBuild.displayName}'s maven project passed the tests.")
                        }
                        failure{
                            slackSend(color: '#FF0000', message: "${currentBuild.displayName}'s maven project failed the tests.")
                        }
                    }
                }
                
                stage('build') {
                    steps {
                        sh 'mvn package -DskipTests=true'
                    }
                    post
                    {
                        success{
                            slackSend(color: '#00FF00', message: "${currentBuild.displayName}'s maven project built successfully.")
                        }
                        failure{
                            slackSend(color: '#FF0000', message: "${currentBuild.displayName}'s maven project failed to build.")
                        }
                    }
                }

                stage('sonarqube') {
                    steps { 
                        withSonarQubeEnv('SonarCloud')
                        {
                            sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar'
                        }
                    }
                    post
                    {
                        success{
                            slackSend(color: '#00FF00', message: "${currentBuild.displayName} scanned successfully")
                        }
                        failure{
                            slackSend(color: '#FF0000', message: "${currentBuild.displayName} failed to scan.")
                        }
                    }
                }
                stage('quality gate'){
                    steps{
                        withSonarQubeEnv('SonarCloud')
                        {
                            timeout(time: 10, unit: 'MINUTES') {
                                // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                                // true = set pipeline to UNSTABLE, false = don't
                                waitForQualityGate abortPipeline: true
                            }
                        }
                    }
                    post
                    {
                        success{
                            slackSend(color: '#00FF00', message: "${currentBuild.displayName} passed the quality gate.")
                        }
                        failure{
                            slackSend(color: '#FF0000', message: "${currentBuild.displayName} failed the quality gate.")
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
                        
                    }
                    post
                    {
                        success{
                            slackSend(color: '#00FF00', message: "${currentBuild.displayName}'s Docker image built successfully")
                        }
                        failure{
                            slackSend(color: '#FF0000', message: "${currentBuild.displayName}'s Docker image failed to build.")
                        }
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
                    post
                    {
                        success{
                            slackSend(color: '#00FF00', message: "${currentBuild.displayName}'s Docker image pushed to Docker Hub")
                        }
                        failure{
                            slackSend(color: '#FF0000', message: "${currentBuild.displayName}'s Docker image failed to push.")
                        }
                    }
                }
            }
            
        }
        
        stage('app deploy') {
            agent {
                docker { 
                    image 'reblank/kubectl_agent' 
                    args '--net=host'}
            }
            steps
            {
                git url: 'https://github.com/re-blank/Jank8-sSampleWebProject'
                withKubeConfig([credentialsId: 'kube-sa', serverUrl: "${kubeMaster}"]) {
                    sh 'kubectl apply -f kubernetes'
                }
            }
            post
            {
                success{
                    slackSend(color: '#00FF00', message: "${currentBuild.displayName} deployed to cluster.")
                }
                failure{
                    slackSend(color: '#FF0000', message: "${currentBuild.displayName} failed to deploy.")
                }
            }
        }
    }
}
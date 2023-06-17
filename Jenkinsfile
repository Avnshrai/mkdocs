pipeline {
    agent any
    stages {
        stage("Checkout the code") {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
                          extensions: [],
                          userRemoteConfigs: [[credentialsId: 'Prometheus', url: 'https://github.com/Avnshrai/mkdocs.git']]])
            }
        }
        stage("Build Docker Image with latest code") {
            steps {
                sh 'sudo docker build -t packaged-mk-docs-image .'
                sh 'sudo chmod +x mkdockerize.sh'
                sh 'echo "Running docker container with latest code"'
                sh 'sudo ./mkdockerize.sh'
            }
        }
    }
}


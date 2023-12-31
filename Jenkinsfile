pipeline {
    agent any
    environment {
        local_directory = sh(script: 'echo "${local_directory}"', returnStdout: true).trim()
    }
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
            environment {
                local_directory = "${local_directory}"
            }
            steps {
                sh 'echo ${local_directory}'
                sh 'sudo docker build -t packaged-mk-docs-image .'
                sh 'sudo chmod +x mkdockerize.sh'
                sh 'sudo docker run -itd -v ${local_directory}:/shared-volume packaged-mk-docs-image produce'
                sh 'sudo docker run -itd -p 8000:8000 -v ${local_directory}:/shared-volume packaged-mk-docs-image serve'
            }
        }
    }
}


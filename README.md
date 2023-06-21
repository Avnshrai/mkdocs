## This project is about using Docker to encapsulate a tool called Mkdocs and serve the local directory to container and run web server on containers

## Pre requisite
Make sure Docker Engine is running and you are good to go 

## Dockerfile

This Dockerfile sets up a Docker image for running an mkdocs server.

# Instructions

1. Dockerfile we are using for building mkdocs server container

```shell
FROM python:3.9-slim
RUN pip3 install --upgrade pip setuptools
RUN pip3 install mkdocs
RUN apt-get update && apt-get install -y tar

WORKDIR /app

COPY mkdockerize.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```
# Note Dockerfile will not start your server we need to run either mkdockerize.sh file with "local_directory" where your code is present or run Jenkins Pipeline 

## Mkdockerize.sh
2. Using mkdockerize.sh file as a entrypoint for docker container which will take produce and serve arguments while running the container

```shell
#!/bin/bash

if [ "$1" = "produce" ]; then
    echo "Creating app.tar.gz from shared volume contents..."
    tar -czf /shared-volume/app.tar.gz -C /shared-volume .
    echo "app.tar.gz created successfully!"
elif [ "$1" = "serve" ]; then
    echo "Unzipping app.tar.gz..."
    tar -xzf /shared-volume/app.tar.gz -C /shared-volume
    echo "app.tar.gz extracted successfully!"
    echo "Starting mkdocs server..."
    mkdocs serve --dev-addr=0.0.0.0:8000 -f /shared-volume/mkdocs.yml
else
    echo "Please provide a valid command: 'produce' or 'serve'"
fi
```   

## Jenkinsfile
3. this is jenkinsfile which is going to build a image using the script and will run a container with the latest image

```shell
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
                sh 'echo "Running docker container with latest code"'
                sh 'sudo ./mkdockerize.sh "${local_directory}"'
            }
        }
    }
}
```
Also we need to define a parameter in Jenkins as we can see below
<img width="1319" alt="Screenshot 2023-06-18 at 12 32 00 PM" src="https://github.com/Avnshrai/mkdocs/assets/33398974/674bd725-5089-49ff-a555-d666e31f45c7">
to add the parameter we will use this parameter option in configuration section of jenkins
 <img width="1305" alt="Screenshot 2023-06-18 at 9 22 53 PM" src="https://github.com/Avnshrai/mkdocs/assets/33398974/ab776984-605a-44fe-a340-1746f926d2a4">




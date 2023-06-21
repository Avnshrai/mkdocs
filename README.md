## This project is about using Docker to encapsulate a tool called Mkdocs and serve the local directory to container and run web server on containers

## Pre requisite
Make sure Docker Engine is running and you are good to go 


# How to run your web server

 Step 1. Copy all the necessary files provided below in the root directory where your mkdocs server files are present 
 Step 2. Create a Docker image by executing the below command
 ```shell
docker build -t "image_name" .
```
Step 3. Now we can run docker run command to produce an app.tar.gz file which will contain everything including your mkdocs server
```shell
docker run -itd -p 8000:8000 -v "local-directory-where-code-is-present":/shared-volume "image_name" produce
```
Replace your "image_name" with the image which you have built in the first step
Step 4. We can start our mkdocs server by running 
```shell
docker run -itd -p 8000:8000 -v "local-directory-where-code-is-present":/shared-volume "image_name" serve
```
## Necessary Files 
## Dockerfile

This Dockerfile sets up a Docker image for running a mkdocs server.

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
# Note Dockerfile will not start your server

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
                sh 'sudo docker run -itd -v ${local_directory}:/shared-volume packaged-mk-docs-image produce'
                sh 'sudo docker run -itd -p 8000:8000 -v ${local_directory}:/shared-volume packaged-mk-docs-image serve'
            }
        }
    }
}
```
Also we need to define a parameter in Jenkins as we can see below
<img width="1319" alt="Screenshot 2023-06-18 at 12 32 00 PM" src="https://github.com/Avnshrai/mkdocs/assets/33398974/674bd725-5089-49ff-a555-d666e31f45c7">
to add the parameter we will use this parameter option in configuration section of jenkins
 <img width="1305" alt="Screenshot 2023-06-18 at 9 22 53 PM" src="https://github.com/Avnshrai/mkdocs/assets/33398974/ab776984-605a-44fe-a340-1746f926d2a4">




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
RUN apt-get update
RUN apt-get -y install zip
RUN mkdir app
WORKDIR /app
EXPOSE 8000
ENTRYPOINT ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000", "-f"]
CMD ["/app/mkdocs.yml"]
```
# Note Dockerfile will not start your server we need to run either mkdockerize.sh file with "local_directory" where your code is present or run Jenkins Pipeline 

## Mkdockerize.sh
2. You can directly run this script and it will do everything for you 

```shell
#!/bin/bash

# Set the container name and image name
CONTAINER_NAME="container_with_no_file"
IMAGE_NAME="mkdocs_image"
CONTAINER_NAME_WITH_FILES="packaged-mk-docs-image"

# Check if the container "new" is running
if [[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME_WITH_FILES" 2>/dev/null)" == "true" ]]; then
    # Stop and remove the container if it is running
    echo "************************************************************"
    echo "Stopping and removing the container '$CONTAINER_NAME_WITH_FILES'..."
    echo "************************************************************"
    docker stop "$CONTAINER_NAME_WITH_FILES" >/dev/null
    docker rm "$CONTAINER_NAME_WITH_FILES" >/dev/null
    echo
else
    # Continue to the next step
    echo "Container '$CONTAINER_NAME_WITH_FILES' is not running. Proceeding to the next step..."
    echo
fi

# Prompt the user to enter the path to the local directory
# Set the local directory from the command-line argument
#read -p "Enter the path to the local directory: " local_directory
local_directory="$1"
echo "Local directory: $local_directory"
echo

local_directory="$1"
#read -p "Enter the path to the local directory: " local_directory
echo "#############"
echo "$local_directory"
echo "#############"
#Build a Image 
echo "************************************************************"
docker build -t mkdocs_image .
# Run the Docker container
echo "************************************************************"
echo "Starting a new container '$CONTAINER_NAME'..."
echo "************************************************************"
docker run -itd -p 8000:8000 -v "$local_directory:/app" --name "$CONTAINER_NAME" "$IMAGE_NAME" 
echo


# Remove the app.tar.gz file if it is already present
echo "************************************************************"
echo "Removing the app.tar.gz file if it is already present..."
echo "************************************************************"
rm -rf app app.tar.gz
echo

# Create a tar.gz file of the /app directory inside the container
echo "************************************************************"
echo "Creating a tar.gz file 'app.tar.gz' in the container..."
echo "************************************************************"
docker exec "$CONTAINER_NAME" tar -czf /app.tar.gz /app 
echo

# Copy the tar.gz file from the container to the host machine
echo "************************************************************"
echo "Copying the tar.gz file 'app.tar.gz' to the current directory..."
echo "************************************************************"
docker cp "$CONTAINER_NAME:/app.tar.gz" ./app.tar.gz 
echo "Tar.gz file 'app.tar.gz' created and copied to the host machine."
echo


# Stop and remove the container
echo "************************************************************"
echo "Stopping and removing the container '$CONTAINER_NAME'..."
echo "************************************************************"
docker stop "$CONTAINER_NAME" >/dev/null
docker rm "$CONTAINER_NAME" >/dev/null
docker rm "$CONTAINER_NAME_WITH_FILES" >/dev/null
echo

# Start a new container and use the app.tar.gz file
echo "************************************************************"
mkdir app
# Extract the .tar.gz file into the app directory on the host
tar -xzf app.tar.gz -C app --strip-components=1

docker run -itd -p 8000:8000 -v "$(pwd)/app:/app" --name "$CONTAINER_NAME_WITH_FILES" "$IMAGE_NAME" >/dev/null
echo "*************************************************************"

# Wait for 3 seconds before checking if the container is running
sleep 3

# Check if the container is running
container_status=$(docker ps -q -f name="$CONTAINER_NAME_WITH_FILES")
if [ -n "$container_status" ]; then
    echo "Container '$CONTAINER_NAME_WITH_FILES' is started successfully."
    echo "You can now visit http://localhost:8000 from your browser to see the website."
else
    echo "Failed to start the container. Please make sure Docker is running and you have Provided a valid local directory for mkdocs"
    exit 1
fi

echo "*************************************************************"
```
And while running mkdockerize.sh file manually we need to provide a env variable as we can see below     
and this file will also create a app.zip file 
```shell
./mkdockerize.sh "your local dir path where code is present"
```

<img width="517" alt="Screenshot 2023-06-18 at 12 33 07 PM" src="https://github.com/Avnshrai/mkdocs/assets/33398974/df167a50-6531-452e-bfc0-3cfc75607e85">

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



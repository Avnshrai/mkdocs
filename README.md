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
docker run -itd -p 8000:8000 -v "$local_directory:/app" --name "$CONTAINER_NAME" "$IMAGE_NAME" >/dev/null
echo
# Remove the app.zip file if it is already present
echo "************************************************************"
echo "Removing the app.zip file if it is already present..."
echo "************************************************************"
rm -rf app.zip
echo
# Create a zip file of the /app directory inside the container
echo "************************************************************"
echo "Creating a zip file 'app.zip' in the container..."
echo "************************************************************"
docker exec -it "$CONTAINER_NAME" zip -r /app.zip /app >/dev/null
echo
# Copy the zip file from the container to the host machine
echo "************************************************************"
echo "Copying the zip file 'app.zip' to the current directory..."
echo "************************************************************"
docker cp "$CONTAINER_NAME:/app.zip" ./app.zip >/dev/null
echo "Zip file 'app.zip' created and copied to the host machine."
echo
# Stop and remove the container
echo "************************************************************"
echo "Stopping and removing the container '$CONTAINER_NAME'..."
echo "************************************************************"
docker stop "$CONTAINER_NAME" >/dev/null
docker rm "$CONTAINER_NAME" >/dev/null
docker rm "$CONTAINER_NAME_WITH_FILES" >/dev/null
echo
# Start the new image container to serve the files
echo "************************************************************"
echo "Starting a container '$CONTAINER_NAME_WITH_FILES' to serve the files..."
echo "************************************************************"
docker run -itd -p 8000:8000 -v "$local_directory:/app" --name "$CONTAINER_NAME_WITH_FILES" "$IMAGE_NAME" >/dev/null
echo "Container '$CONTAINER_NAME_WITH_FILES' is started successfully."
echo "You can now visit http://localhost:8000 from your browser to see the website."
echo "*************************************************************"
```
And while running mkdockerize.sh file manually we need to provide a env variable as we can see below                                                                 
EX -> 
./mkdockerize.sh "your local dir path where code is present"

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



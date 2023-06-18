Dockerfile 

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

Mkdockerize.sh

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











Jenkinsfile

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

I have defined a parameter in jenkins pipeline which is taking local_directory as a env variable as we can see below(by default there is value where jenkins is cloning the repo) 

And while running mkdockerize.sh file manually we need to provide a env variable as we can see in the below image 



The procedure entails the creation of a Docker image using the provided Dockerfile, followed by the execution of a container. A volume is specified to map our local directory path, enabling the construction of the mkdocs server and the generation of an app.tar file. Subsequently, another container is launched to utilize the aforementioned tar file. Upon accessing the browser and navigating to localhost:8000, the operational server will be visible.



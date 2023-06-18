markdown
Copy code
# Dockerfile

This Dockerfile sets up a Docker image for running an mkdocs server.

## Instructions

1. Build the Docker image by running the following command:

```shell
docker build -t mkdocs_image .
Run the Docker container using the following command:
shell
Copy code
docker run -itd -p 8000:8000 -v [LOCAL_DIRECTORY]:/app --name container_with_no_file mkdocs_image
Replace [LOCAL_DIRECTORY] with the path to your local directory.

Access the mkdocs server by opening a browser and navigating to http://localhost:8000.
Mkdockerize.sh
This shell script automates the process of creating and running a Docker container for the mkdocs server.

Instructions
Make the script executable by running the following command:
shell
Copy code
chmod +x mkdockerize.sh
Execute the script with the following command:
shell
Copy code
./mkdockerize.sh [LOCAL_DIRECTORY]
Replace [LOCAL_DIRECTORY] with the path to your local directory.

The script will build the Docker image, start a new container, create and copy the app.zip file, and finally start a container to serve the files. You can access the mkdocs server by opening a browser and navigating to http://localhost:8000.
Jenkinsfile
This Jenkinsfile defines a Jenkins pipeline for building and running the mkdocs server in a Docker container.

Instructions
Set up a Jenkins job and configure it to use this Jenkinsfile.

The pipeline will clone the repository and build a Docker image with the latest code.

The pipeline will then run the mkdockerize.sh script with the specified [LOCAL_DIRECTORY] environment variable.

The script will build the Docker image, start a new container, create and copy the app.zip file, and finally start a container to serve the files. You can access the mkdocs server by opening a browser and navigating to http://localhost:8000.

Make sure to replace `[LOCAL_DIRECTORY]` with the actual path to your local directory in the instructions provided.




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
read -p "Enter the path to the local directory: " local_directory
echo "#############"
echo "$local_directory"
echo "#############"
#Build a Image
echo "************************************************************"
docker build -t mkdocs_image .


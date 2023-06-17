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

# Commit the container to create a new image and start a container to serve the directory
echo "************************************************************"
echo "Committing the container '$CONTAINER_NAME' to create a new image '$CONTAINER_NAME_WITH_FILES'..."
echo "************************************************************"
docker commit "$CONTAINER_NAME" "$CONTAINER_NAME_WITH_FILES" >/dev/null
echo

# Stop and remove the container
echo "************************************************************"
echo "Stopping and removing the container '$CONTAINER_NAME'..."
echo "************************************************************"
docker stop "$CONTAINER_NAME" >/dev/null
docker rm "$CONTAINER_NAME" >/dev/null
echo

# Start the new image container to serve the files
echo "************************************************************"
echo "Starting a container '$CONTAINER_NAME_WITH_FILES' to serve the files..."
echo "************************************************************"
docker run -itd -p 8000:8000 --name "$CONTAINER_NAME_WITH_FILES" "$CONTAINER_NAME_WITH_FILES" >/dev/null
echo "Container '$CONTAINER_NAME_WITH_FILES' is started successfully."
echo "You can now visit http://localhost:8000 from your browser to see the website."
echo "*************************************************************"



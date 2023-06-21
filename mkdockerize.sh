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

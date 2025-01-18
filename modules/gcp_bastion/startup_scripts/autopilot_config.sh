#!/bin/bash
sudo apt update -y
sudo apt install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin

# Add your startup commands here

# Example command
echo "Hello, World!" > /var/log/startup.log

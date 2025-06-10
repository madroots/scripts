#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Prompt the user to confirm Docker installation
read -rp "Do you want to install Docker? (y/n): " confirmation

if [ "$confirmation" != "y" ]; then
    echo "Docker installation cancelled."
    exit 1
fi

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Wait for the installation to complete
wait

clear
echo "Docker installed successfully."

# Docker Compose Installation
echo "Now, let's install Docker Compose."

# URL of the GitHub releases page for Docker Compose
url="https://github.com/docker/compose/releases"

# Use curl to fetch the HTML content of the releases page
html_content=$(curl -s "$url")

# Extract the latest version from the HTML content
latest_version=$(echo "$html_content" | grep -oP '(?<=/docker/compose/releases/tag/)[^"]+' | head -n 1)
arch=$(uname -m)

echo "Latest Docker Compose version: $latest_version"

# Create directory for Docker CLI plugins
mkdir -p ~/.docker/cli-plugins/

# Install Docker Compose
sudo curl -SL "https://github.com/docker/compose/releases/download/$latest_version/docker-compose-linux-$arch" -o /usr/local/bin/docker-compose

# Confirm Docker Compose installation
echo "Checking Docker Compose version:"
sudo chmod +x /usr/local/bin/docker-compose && docker-compose --version

if groups "$(logname)" | grep -qw docker; then
    echo "User is already in the docker group."
else
    echo "Added user to the docker group. Please log out and back in (or reboot) to activate it."
fi

# Clean up
rm get-docker.sh

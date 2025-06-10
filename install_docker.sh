#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root or with sudo."
    exit 1
fi

# Prompt user to confirm Docker installation
read -rp "Do you want to install Docker? (y/n): " confirmation
if [[ "$confirmation" != "y" ]]; then
    echo "🚫 Docker installation cancelled."
    exit 0
fi

# Determine the user who invoked sudo or root user
REAL_USER=${SUDO_USER:-$(logname)}

# Install Docker
echo "📦 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
rm -f get-docker.sh
echo "✅ Docker installed successfully."

# Install Docker Compose
echo "🔧 Installing Docker Compose..."
compose_url="https://github.com/docker/compose/releases"
html_content=$(curl -s "$compose_url")
latest_version=$(echo "$html_content" | grep -oP '(?<=/docker/compose/releases/tag/)[^"]+' | head -n 1)
arch=$(uname -m)

mkdir -p /home/"$REAL_USER"/.docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/$latest_version/docker-compose-linux-$arch" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "✅ Docker Compose installed. Version:"
docker-compose --version

# Ensure docker group exists
if ! getent group docker > /dev/null; then
    echo "➕ Creating docker group..."
    groupadd docker
else
    echo "ℹ️ Docker group already exists."
fi

# Add user to docker group
usermod -aG docker "$REAL_USER"
echo "👤 Added user '$REAL_USER' to the docker group."

echo ""
echo "🚀 Installation completed successfully."
echo "🔁 Please log out and back in (or reboot) for group changes to take effect."

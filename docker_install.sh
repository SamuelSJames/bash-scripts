#!/bin/bash

echo "Docker and Docker Compose Installation Script for Ubuntu.."
sleep 5
# Exit on any error
set -e

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update package index and install prerequisites
echo "Preparing for Docker installation..."
apt-get update
apt-get install -y ca-certificates curl

# Create keyrings directory
mkdir -p /etc/apt/keyrings

# Add Docker's official GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo "Configuring Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
apt-get update

# Install Docker components
echo "Installing Docker components..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify Docker installation
echo "Verifying Docker installation..."
docker run hello-world

# Get latest Docker Compose version
echo "Fetching latest Docker Compose version..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

# Install Docker Compose
echo "Installing Docker Compose ${COMPOSE_VERSION}..."
curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

# Add Docker Compose bash completion
echo "Adding Docker Compose bash completion..."
curl -L "https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose" -o /etc/bash_completion.d/docker-compose

# Optional: Add current user to docker group
read -p "Do you want to add the current user to docker group? (y/n): " add_user
if [[ $add_user == "y" ]]; then
    current_user=$(logname)
    usermod -aG docker $current_user
    echo "User $current_user added to docker group"
fi

# Output versions
echo "Docker version:"
docker --version
echo "Docker Compose version:"
docker-compose -v

echo "Docker and Docker Compose installation completed successfully!"

exit 0

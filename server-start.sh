#!/bin/bash

# Update and upgrade the system
echo "Updating and upgrading Ubuntu..."
sudo apt-get update && sudo apt-get upgrade -y

# Install prerequisites
echo "Installing prerequisites for Docker..."
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y

# Add Docker’s official GPG key and repository
echo "Adding Docker’s official GPG key and repository..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package database and install Docker
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Install Docker Compose
echo "Installing the latest Docker Compose..."
DOCKER_COMPOSE_LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_LATEST_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


# Check if user wants to set ArvanCloud mirror
read -p "Do you want to set ArvanCloud Docker mirror? (yes/no): " use_arvancloud

if [ "$use_arvancloud" == "yes" ]; then
  echo "Setting ArvanCloud Docker mirror..."
  sudo bash -c 'cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries" : ["https://docker.arvancloud.ir"],
  "registry-mirrors": ["https://docker.arvancloud.ir"]
}
EOF'
  docker logout
  sudo systemctl restart docker
  echo "Docker daemon restarted with ArvanCloud mirror."
else
  echo "ArvanCloud Docker mirror not set."
fi

# Display Docker and Docker Compose versions
docker --version
docker-compose --version

echo "Installation complete."

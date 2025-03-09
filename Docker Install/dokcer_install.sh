#!/bin/bash

# Define log file
LOGFILE="/var/log/docker_install.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# Functions for logging messages
log() {
    echo -e "$GREEN[✔] $1 $RESET"
}

warn() {
    echo -e "$YELLOW[!] $1 $RESET"
}

error() {
    echo -e "$RED[✖] $1 $RESET" 1>&2
    exit 1
}

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root! Use sudo ./install-docker.sh"
fi

log "Updating package database..."
sudo apt-get update -y || error "Failed to update package database!"

log "Installing prerequisites..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common || error "Failed to install required packages!"

log "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || error "Failed to add Docker's GPG key!"

log "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || error "Failed to add Docker repository!"

log "Updating package database again..."
sudo apt-get update -y || error "Failed to update package database!"

log "Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io || error "Docker installation failed!"

log "Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

log "Adding current user to the Docker group..."
sudo usermod -aG docker $USER || warn "Failed to add user to Docker group!"

log "Verifying Docker installation..."
if docker --version; then
    log "Docker installed successfully!"
else
    error "Docker installation failed!"
fi

log "Testing Docker with Hello-World container..."
if sudo docker run hello-world; then
    log "Docker is working perfectly!"
else
    warn "Docker test failed!"
fi

log "Cleaning up unnecessary packages..."
sudo apt-get autoremove -y && sudo apt-get clean -y

log "Installation complete! Please restart your terminal or run 'newgrp docker' to apply user changes."
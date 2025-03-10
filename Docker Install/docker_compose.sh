#!/bin/bash

# 🚨 Exit script on error
set -e

echo -e "\033[1;34m🔄 Updating system packages...\033[0m"
sudo apt update -y && sudo apt upgrade -y

echo -e "\033[1;34m📦 Installing dependencies (curl & jq)...\033[0m"
sudo apt install -y curl jq

echo -e "\033[1;34m🌍 Fetching the latest Docker Compose version...\033[0m"
LATEST_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)

# 🛑 If jq fails, set a fallback version
if [[ "$LATEST_COMPOSE_VERSION" == "null" || -z "$LATEST_COMPOSE_VERSION" ]]; then
    LATEST_COMPOSE_VERSION="v2.20.3" # Default version if API fails
    echo -e "\033[1;33m⚠️ Warning: Unable to fetch the latest version. Using default: $LATEST_COMPOSE_VERSION\033[0m"
fi

echo -e "\033[1;32m⬇️ Downloading Docker Compose ($LATEST_COMPOSE_VERSION)...\033[0m"
sudo curl -L "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# ✅ Set executable permissions
sudo chmod +x /usr/local/bin/docker-compose

# 🔍 Verify installation
echo -e "\033[1;34m🔎 Verifying Docker Compose installation...\033[0m"
docker-compose --version && echo -e "\033[1;32m✅ Docker Compose installed successfully!\033[0m"

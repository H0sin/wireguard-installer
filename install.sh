#!/bin/bash
#1
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

clear
echo -e "${GREEN}🚀 WireGuard panel auto-installation is in progress...${NC}\n"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}⛔ Please run the script as root!${NC}\n"
  exit 1
fi

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}🌍 Server IP: $SERVER_IP${NC}\n"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}🛠 Docker is not installed. Installing Docker...${NC}\n"
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
fi

# Check if Docker Compose is installed
if ! command -v docker compose &> /dev/null; then
    echo -e "${YELLOW}🛠 Installing Docker Compose...${NC}\n"
    sudo apt-get install -y docker-compose
fi

# Installation directory
INSTALL_DIR="/root/Wireguard"

# Get GitHub credentials
read -p "📝 Enter your GitHub username: " GITHUB_USER
read -s -p "🔑 Enter your GitHub personal access token: " GITHUB_TOKEN
echo -e "\n"

# Remove existing version if present
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️ Existing project found. Removing and reinstalling...${NC}\n"
    rm -rf $INSTALL_DIR
fi

# Clone private GitHub repository
echo -e "${GREEN}📥 Cloning project from GitHub...${NC}\n"
git clone https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/Wireguard.git $INSTALL_DIR

# Check if cloning was successful
if [[ $? -ne 0 ]]; then
    echo -e "${RED}⛔ Error cloning the project! Please check your token and username.${NC}\n"
    exit 1
fi

# Replace server IP in configuration files
echo -e "${YELLOW}🔄 Replacing server IP in configuration files...${NC}\n"
cd $INSTALL_DIR

# Start Docker Compose
echo -e "${GREEN}🚀 Starting the service...${NC}\n"
cd $INSTALL_DIR
docker compose up -d

echo -e "${GREEN}✅ Installation and setup completed successfully!${NC}\n"
echo -e "🌍 Access the panel at: http://$SERVER_IP"

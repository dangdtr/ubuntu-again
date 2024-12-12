#!/bin/bash

# Update package list
sudo apt-get update -y

# Install required packages
sudo apt-get install -y fuse libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin
wget -c https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz
sudo tar -xzf jetbrains-toolbox-2.5.2.35332.tar.gz -C /opt

sudo apt install -y git
sudo snap install --classic code
sudo apt install -y flameshot nautilus

# Generate SSH key and add to ssh-agent
ssh-keygen -t rsa -b 4096 -C "dang.dt@teko.vn" -f ~/.ssh/id_rsa_gl_teko -N ""
ssh-add ~/.ssh/id_rsa_gl_teko
echo -e "Host git.teko.vn\n    HostName https://git.teko.vn\n    IdentityFile ~/.ssh/id_rsa_gl_teko" >> ~/.ssh/config

# Create Kubernetes config directory
mkdir -p ~/.kube
touch ~/.kube/config

# Install Docker and Docker Compose
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get update -y
sudo apt install -y docker-ce
sudo usermod -aG docker ${USER}
sudo curl -L "https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install IBus Bamboo
sudo add-apt-repository -y ppa:bamboo-engine/ibus-bamboo
sudo apt-get update -y
sudo apt-get install -y ibus ibus-bamboo --install-recommends
ibus restart
env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" 
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"

echo "Setup complete. Please restart your machine to apply all changes."

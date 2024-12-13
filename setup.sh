#!/bin/bash

# Update package list
sudo apt-get update -y

# Install required packages
sudo apt-get install -y fuse libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin
git flameshot nautilus apt-transport-https ca-certificates curl gnupg

# Install JetBrains Toolbox
wget -c https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-2.5.2.35332.tar.gz
sudo tar -xzf jetbrains-toolbox-2.5.2.35332.tar.gz -C /opt

# Install VS Code
sudo snap install --classic code

# Install Spotify
sudo snap install spotify

# Generate SSH key and add to ssh-agent
ssh-keygen -t rsa -b 4096 -C "dang.dt@teko.vn" -f ~/.ssh/id_rsa_gl_teko -N ""
ssh-add ~/.ssh/id_rsa_gl_teko
echo -e "Host git.teko.vn\n    HostName https://git.teko.vn\n    IdentityFile ~/.ssh/id_rsa_gl_teko" >> ~/.ssh/config

# Create Kubernetes config directory
mkdir -p ~/.kube
touch ~/.kube/config

# Install Docker and Docker Compose
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get update -y
sudo apt install -y docker-ce
groupadd docker
sudo usermod -aG docker ${USER}
sudo curl -L "https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install IBus Bamboo
sudo add-apt-repository -y ppa:bamboo-engine/ibus-bamboo
sudo apt-get update -y
sudo apt-get install -y ibus ibus-bamboo --install-recommends
ibus restart
env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" 
gsettings set org.gnome.desktop.input-sources sources "[(\'xkb\', \'us\'), (\'ibus\', \'Bamboo\')]"

# Install Kubernetes CLI (kubectl)
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubectl

# Install Krew (kubectl plugin manager)
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./${KREW} install krew
)

# Configure Krew PATH
if [ -n "$ZSH_VERSION" ]; then
    CONFIG_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    CONFIG_FILE="$HOME/.bashrc"
else
    echo 'Add the following line manually to your shell config:'
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"'
    exit 1
fi

if ! grep -q 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' "$CONFIG_FILE"; then
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> "$CONFIG_FILE"
    echo "Added to $CONFIG_FILE. Run 'source $CONFIG_FILE' to apply changes."
else
    echo "PATH is already configured in $CONFIG_FILE."
fi

kubectl krew update

# Install Krew plugins
kubectl krew install access-matrix
kubectl krew install oidc-login

# Install k9s
# wget https://github.com/derailed/k9s/releases/download/v0.32.7/k9s_linux_amd64.deb
# sudo apt install ./k9s_linux_amd64.deb
# rm k9s_linux_amd64.deb
sudo snap install k9s --devmode

# Setup kubectl
kubectl config use-context  teko-dev
kubectl config set-context --current --namespace=devx


# Final message
echo "Setup complete. Please restart your machine to apply all changes."

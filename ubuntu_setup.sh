#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

#intellij
sudo snap install intellij-idea-community --classic

#jdk
sudo apt install openjdk-16-jdk -y

#docker

#check below if works
#sudo apt-get install docker.io
#docker --version

sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io -y

#sudo groupadd docker

sudo usermod -aG docker $USER

newgrp docker

docker run hello-world

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose --version

#vs code
sudo snap install --classic code

#maven
#sudo apt-get install maven -y

#chrome
#wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#sudo apt install ./google-chrome-stable_current_amd64.deb

#mozilla firefox
sudo apt install firefox -y
firefox --version

#direnv
sudo apt install direnv -y

#misc
sudo apt-get install jq -y
sudo apt-get install httpie -y
sudo apt-get install terminator -y
sudo apt install net-tools

#zsh
sudo apt-get install fonts-powerline -y
sudo apt install zsh -y
zsh --version
chsh -s $(which zsh)
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
chmod 744 install.sh
sh install.sh

#time
sudo timedatectl set-timezone Asia/Singapore

#maven
mkdir ~/bin && cd ~/bin
wget https://www-eu.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz
tar -xzf apache-maven-3.8.1-bin.tar.gz
echo "export M2_HOME=~/bin/apache-maven-3.8.1" >> ~/.bashrc
echo "export PATH=$PATH:$M2_HOME/bin" >> ~/.bashrc


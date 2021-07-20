#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install git
git --version

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker pi
docker version

sudo apt-get install httpie
sudo apt-get install jq

mkdir ~/bin && cd ~/bin
wget https://downloads.apache.org/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz
tar -xzf apache-zookeeper-3.7.0-bin.tar.gz

wget https://www-eu.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-    maven-3.8.1-bin.tar.gz
tar -xzf apache-maven-3.8.1-bin.tar.gz
echo "export M2_HOME=~/bin/apache-maven-3.8.1" >> ~/.bashrc
echo "export PATH=$PATH:$M2_HOME/bin" >> ~/.bashrc


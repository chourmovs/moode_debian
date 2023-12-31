#!/bin/bash
printf "\ec"
echo ""
echo "****************************************************"
echo "*     latest podman and qemu install script        *"
echo "*             By chourmovs                         *"
echo "****************************************************"
echo ""
echo ""
sudo rm /etc/apt/sources.list.d/sid.list
sudo apt update -y
sudo apt install aptitude
echo 'APT::Default-Release "bullseye";' | sudo tee /etc/apt/apt.conf.d/00default
sudo cat /etc/apt/sources.list.d/sid.list
echo 'deb https://deb.debian.org/debian sid main' > /etc/apt/sources.list.d/sid.list
sudo aptitude -q -y install podman
sudo rm /etc/apt/sources.list.d/sid.list
sudo apt update -y

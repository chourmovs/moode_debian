#!/bin/bash

printf "\ec"
echo ""
echo "****************************************************"
echo "*    Moode on docker multiarch install script    *"
echo "*             By chourmovs v 1.1                  *"
echo "****************************************************"
echo ""
echo ""
echo ""
echo ""
echo "****************************************************"
echo "*           Install Docker if necessary            *"
echo "****************************************************"
echo ""
# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg
sudo install -y -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sleep 2
sudo apt update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ""
echo ""
echo ""
echo "****************************************************"
echo "*            install multiarch qemu layers         *"
echo "****************************************************"
echo "" 
sleep 2

# sudo docker run --privileged --rm tonistiigi/binfmt --install all
# sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes # This step will execute the registering scripts

echo "" 
echo "************************************************************************"
echo "*    create container with systemd in priviledged mode and start it    *"
echo "************************************************************************"
echo ""

sudo docker volume create moode

sudo docker create --name debian-moode --restart always -v moode:/mnt/NAS -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
--privileged -e LANG=C.UTF-8 --cap-add=NET_ADMIN --security-opt seccomp:unconfined --net host \
--tmpfs /tmp --tmpfs /run --tmpfs /run/lock \
navikey/raspbian-bullseye /lib/systemd/systemd log-level=info unit=sysinit.target

sudo docker container start debian-moode

echo ""
echo ""
echo "*********************************************"
echo "*        install vital dependecies          *"
echo "*********************************************"
echo ""
echo ""

sudo docker exec -ti debian-moode /bin/bash -c "apt-get update -y | apt-get upgrade -y"
# sudo docker exec -ti debian-moode /bin/bash -c "apt-get install -y sssd sssd-dbus --fix-missing"
sudo docker exec -ti debian-moode /bin/bash -c "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils nfs-common"
sudo docker exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"
echo ""
echo ""


echo ""
echo ""
echo "Will change ssh port to 2222 to fix openssh"
echo ""
echo ""
sleep 3

sudo docker exec -ti debian-moode /bin/bash -c "sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config;"
sudo docker exec -ti debian-moode /bin/bash -c "systemctl restart sshd"


echo ""
echo "*********************************************"
echo "*        install moode player               *"
echo "*********************************************"
echo ""
sleep 1

sudo docker exec -ti debian-moode /bin/bash -c "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash -"
sudo docker exec -ti debian-moode /bin/bash -c "apt-get update -y"
sudo docker exec -ti debian-moode /bin/bash -c "apt-get install udisks nginx triggerhappy samba dnsmasq -y"
echo ""
echo ""


sudo docker exec -ti debian-moode /bin/bash -c "apt-get install moode-player -y --fix-missing"
echo ""
echo ""
echo ""
echo "In general this long install return error, next move will try to fix this"
echo ""
echo ""
echo ""
sudo docker exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"
sleep 1
echo ""
echo ""
echo ""
sudo docker exec -ti debian-moode /bin/bash -c "apt-get install moode-player -y --fix-missing"
sleep 1
echo ""
echo ""
echo ""
sudo docker exec -ti debian-moode /bin/bash -c "apt upgrade -y"
#sleep 1
echo ""
echo ""
echo ""
sudo docker exec -ti debian-moode /bin/bash -c "exit"       
echo ""

echo ""
echo ""
echo "****************************************"
echo "*    restart moode player (host side)  *"
echo "****************************************"

sudo docker container stop debian-moode
sudo docker container start debian-moode

echo ""
echo ""
echo "***************************************"
echo "*    configure nginx (container side) *"
echo "***************************************"
echo ""
echo "Will change moode http port to 8008 to avoid conflict with volumio front"
echo ""
echo ""
sleep 1
sudo docker exec -ti debian-moode /bin/bash -c "sudo sed -i 's/80 /8008 /g' /etc/nginx/sites-available/moode-http.conf"
sudo docker exec -ti debian-moode /bin/bash -c "systemctl start my-service@* --all"
sudo docker exec -ti debian-moode /bin/bash -c "systemctl restart nginx"

echo ""
echo "****************************"
echo "*    Access Moode web UI   *"
echo "****************************"
echo ""
echo ""
echo "Your device will now restart"
echo ""
echo ""
echo "CTRL+CLIC on http://moode:8008"
echo ""
echo "Enjoy"
# sudo reboot


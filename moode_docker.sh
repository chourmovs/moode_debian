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
echo "*                 Activate Podman                  *"
echo "****************************************************"
echo ""
podman machine init
podman machine stop
podman machine set --rootful
podman machine start
echo ""
echo ""
echo ""
echo "****************************************************"
echo "*            install multiarch qemu layers         *"
echo "****************************************************"
echo ""
sleep 3

sudo podman run --privileged --rm tonistiigi/binfmt --install all
sudo podman run --rm --privileged multiarch/qemu-user-static --reset -p yes # This step will execute the registering scripts

echo ""
echo ""
echo ""
echo "********************************************************************************************"
echo "*   Optional - If you want Moode to get an exlusive access to vital service MPD,CIFS,NFS   *"
echo "********************************************************************************************"
echo ""
echo ""
sudo apt remove dnsmasq -y
echo ""
echo ""
echo ""
echo "************************************************************************"
echo "*    create container with systemd in priviledged mode and start it    *"
echo "************************************************************************"
echo ""
echo ""
sudo podman create --name debian-moode --restart always --network=host --security-opt seccomp:unconfined --privileged navikey/raspbian-bullseye /lib/systemd/systemd
sudo podman container start debian-moode
sleep 5
# podman exec -ti debian-moode /bin/bash -c "ip addr show"
sleep 5

echo ""
echo "*********************************************"
echo "*        install vital dependecies          *"
echo "*********************************************"
echo ""
sleep 3

sudo podman exec -ti debian-moode /bin/bash -c "apt-get update -y ; sleep 3 ; apt-get upgrade -y"
sudo podman exec -ti debian-moode /bin/bash -c "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils"
sudo podman exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"
echo ""
echo ""
read -p "Press any key to continue... " -n1 -s

echo ""
echo ""
echo "Will change ssh port to 2222 to fix openssh"
echo ""
echo ""
sleep 1

sudo podman exec -ti debian-moode /bin/bash -c "sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config;"
sudo podman exec -ti debian-moode /bin/bash -c "systemctl restart sshd"


echo ""
echo "*********************************************"
echo "*        install moode player               *"
echo "*********************************************"
echo ""
sleep 1

sudo podman exec -ti debian-moode /bin/bash -c "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash -"
sudo podman exec -ti debian-moode /bin/bash -c "apt-get update -y"
sudo podman exec -ti debian-moode /bin/bash -c "systemctl start my-service@* --all"
sudo podman exec -ti debian-moode /bin/bash -c "apt-get install udisks nginx triggerhappy samba dnsmasq -y"
sudo podman exec -ti debian-moode /bin/bash -c "systemctl start my-service@* --all"
echo ""
echo ""
read -p "Press any key to continue... " -n1 -s

sudo podman exec -ti debian-moode /bin/bash -c "apt-get install moode-player -y --fix-missing"
echo ""
echo ""
echo ""
echo "In general this long install return error, next move will try to fix this"
echo ""
echo ""
echo ""
sudo podman exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"
sleep 1
echo ""
echo ""
echo ""
sudo podman exec -ti debian-moode /bin/bash -c "apt-get install moode-player -y --fix-missing"
sleep 1
echo ""
echo ""
echo ""
sudo podman exec -ti debian-moode /bin/bash -c "apt upgrade -y"
#sleep 1
echo ""
echo ""
echo ""
sudo podman exec -ti debian-moode /bin/bash -c "exit"       
echo ""

echo ""
echo ""
echo "****************************************"
echo "*    restart moode player (host side)  *"
echo "****************************************"

sudo podman container stop debian-moode
sudo podman container start debian-moode

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
sudo podman exec -ti debian-moode /bin/bash -c "sudo sed -i 's/80 /8008 /g' /etc/nginx/sites-available/moode-http.conf"
sudo podman exec -ti debian-moode /bin/bash -c "systemctl start my-service@* --all"
sudo podman exec -ti debian-moode /bin/bash -c "systemctl restart nginx"

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


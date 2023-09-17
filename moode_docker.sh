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
echo "****************************************************"
echo "*               Download scripts                   *"
echo "****************************************************"
echo ""

curl -o Dockerfile  'https://raw.githubusercontent.com/chourmovs/moode_debian/qemu/Dockerfile'
curl -o initctl_faker 'https://raw.githubusercontent.com/chourmovs/moode_debian/qemu/initctl_faker'


echo "************************************************************************"
echo "*    create container with systemd in priviledged mode and start it    *"
echo "************************************************************************"
echo ""
echo ""

echo "buildah build -t localhost/debian-arm -f Dockerfile ."
sudo buildah build -t localhost/debian-arm -f Dockerfile .
echo ""
echo ""
echo "podman run --systemd=always"
sudo docker volume create moode
sudo podman run --systemd=always -td --name=debian-arm -v moode:/sys:rw -vmoode:/boot:rw --network=host --arch=arm --privileged --security-opt seccomp:unconfined \
--entrypoint=/usr/bin/qemu-arm-static localhost/debian-arm -execve -0 /sbin/init /sbin/init 
echo ""
echo ""


podman generate systemd --new --files -n debian-arm
sudo cp /home/$USER/container-debian-arm.service /etc/systemd/system
systemctl daemon-reload
systemctl start container-debian-arm


sleep 2
# podman exec -ti debian-moode /bin/bash -c "ip addr show"
sleep 2

echo ""
echo "*********************************************"
echo "*        install vital dependecies          *"
echo "*********************************************"
echo ""
sleep 2

echo "mv /bin/sh.real /bin/sh ; apt-get update -y ; sleep 3 ; apt-get upgrade -y"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "mv /bin/sh.real /bin/sh ; apt-get update -y ; sleep 3 ; apt-get upgrade -y"

echo "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils"

echo "apt --fix-broken install -y"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt --fix-broken install -y"
echo ""
echo ""
# read -p "Press any key to continue... " -n1 -s

echo ""
echo ""
echo "Will change ssh port to 2222 to fix openssh"
echo ""
echo ""

sleep 1
echo "sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config"
echo ""
echo ""
echo "systemctl restart sshd"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "systemctl restart sshd"
echo ""
echo ""
echo ""
echo "*********************************************"
echo "*        install moode player               *"
echo "*********************************************"
echo ""
sleep 1
echo "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash -"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash -"
echo ""
echo ""

echo "apt-get update -y"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get update -y"
echo ""
echo "apt-get install udisks nginx triggerhappy samba dnsmasq -y"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install udisks nginx triggerhappy samba dnsmasq -y"
echo ""
echo ""
#read -p "Press any key to continue... " -n1 -s

echo "apt-get install moode-player -y --fix-missing"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install moode-player -y --fix-missing"
echo ""
echo ""
echo ""
echo "In general this long install return error, next move will try to fix this"
echo ""
echo ""
echo "apt --fix-broken install -y"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt --fix-broken install -y"
sleep 1
echo ""
echo ""
echo "apt-get install moode-player -y --fix-missing"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install moode-player -y --fix-missing"
sleep 1
echo ""
echo ""
echo "apt upgrade -y"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt upgrade -y"
#sleep 1
echo ""
echo ""
echo ""  
echo ""

echo ""
echo ""
echo "****************************************"
echo "*    restart moode player (host side)  *"
echo "****************************************"

systemctl stop container-debian-moode

echo "podman container stop debian-moode"
#sudo podman container stop debian-arm
echo "podman container start debian-moode"
#sudo podman container start debian-arm
systemctl start container-debian-moode

echo ""
echo ""
echo "***************************************"
echo "*    configure nginx (container side) *"
echo "***************************************"
echo ""
echo ""
echo "Will change moode http port to 8008 to avoid conflict with volumio front"
echo ""
echo ""
echo "sudo sed -i 's/80 /8008 /g' /etc/nginx/sites-available/moode-http.conf"
sleep 1
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "sudo sed -i 's/80 /8008 /g' /etc/nginx/sites-available/moode-http.conf"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "systemctl restart nginx"

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


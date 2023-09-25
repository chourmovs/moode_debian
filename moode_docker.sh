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
echo "dockerfile"
curl -o Dockerfile  'https://raw.githubusercontent.com/chourmovs/moode_debian/qemu/Dockerfile'
echo "initctl_faker"
curl -o initctl_faker 'https://raw.githubusercontent.com/chourmovs/moode_debian/qemu/initctl_faker'
echo ""
echo ""
echo "scripts downloaded"
echo ""

echo "************************************************************************"
echo "*    create container with systemd in priviledged mode and start it    *"
echo "************************************************************************"
echo ""
echo ""
sudo buildah build -t localhost/debian-arm -f Dockerfile .
echo ""
echo ""
echo ""
#sudo podman volume create moode
cd ~ && sudo mkdir -p moode/{sys,boot}
sudo podman run --systemd=always -td --user=root --name=debian-arm --network=host --arch=arm --entrypoint=/sbin/init --log-level=debug --privileged --security-opt seccomp:unconfined \
--entrypoint=/usr/bin/qemu-arm-static localhost/debian-arm -execve -0 /sbin/init /sbin/init 
echo ""
echo "podman container created...."


#sudo podman generate systemd --new --files -n debian-arm
#sudo cp /home/$USER/container-debian-arm.service /etc/systemd/system
#systemctl daemon-reload
#systemctl start container-debian-arm


sleep 2
# podman exec -ti debian-moode /bin/bash -c "ip addr show"
sleep 2

echo ""
echo "*********************************************"
echo "*        install vital dependecies          *"
echo "*********************************************"
echo ""
sleep 2

echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "mv /bin/sh.real /bin/sh ; apt-get update -y ; sleep 3 ; apt-get upgrade -y"

echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils wget alsa-utils"

#sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "curl -o /etc/asound.conf  'https://raw.githubusercontent.com/chourmovs/moode_debian/qemu/asound.conf'"
#sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "systemctl restart alsa-utils"

echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt --fix-broken install -y"
echo ""
echo "vital dependencies installed"
# read -p "Press any key to continue... " -n1 -s

echo ""
echo ""
echo "Will change ssh port to 2222 to fix openssh"
sleep 1
echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config"
echo ""
echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "systemctl restart sshd"
echo ""
echo "*********************************************"
echo "*        install moode player               *"
echo "*********************************************"
echo ""
sleep 1
echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash - "
echo ""
echo ""

echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get update -y"
echo ""
echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install udisks -y"
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "export DEBIAN_FRONTEND=noninteractive | rm -rf /var/lib/dpkg/info/udisks.postinst | yes "" | dpkg --configure -a |yes "" | unset DEBIAN_FRONTEND"
# read -p "Udisk finished Press any key to continue... " -n1 -s

sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install nginx triggerhappy samba dnsmasq -y"
echo ""
echo ""
#read -p "Press any key to continue... " -n1 -s

echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install moode-player -y --fix-missing"

sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "curl -o /etc/mpd.conf https://raw.githubusercontent.com/chourmovs/moode_debian/qemu/mpd.conf"

echo ""
echo ""
echo ""
echo "In general this long install return error, next move will try to fix this"
echo ""
echo ""
echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt --fix-broken install -y"
sleep 1
echo ""
echo ""
echo ""
sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install moode-player -y --fix-missing"
sleep 1
echo ""
echo ""
echo ""  
echo ""

echo ""
echo ""
echo "****************************************"
echo "*    restart moode player (host side)  *"
echo "****************************************"

#systemctl stop container-debian-moode

echo "podman container stop debian-moode"
sudo podman container stop debian-arm -t 40
echo "podman container start debian-moode"
sudo podman container start debian-arm
#systemctl start container-debian-moode

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
# sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "systemctl start mpd.socket mpd.service"

#sudo podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "/sbin/init u"


echo ""
echo "****************************"
echo "*    Access Moode web UI   *"
echo "****************************"
echo ""
echo ""
# echo "Your device will now restart"
echo ""
echo ""
echo "CTRL+CLIC on http://localhost:8008"
echo ""
echo "Enjoy"
# sudo reboot


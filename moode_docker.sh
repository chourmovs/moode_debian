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

curl -o Dockerfile  'https://raw.githubusercontent.com/chourmovs/moode_debian/qemu/Dockerfile'
curl -o initctl_faker 'https://raw.githubusercontent.com/chourmovs/moode_debian/qemu/initctl_faker'


echo "************************************************************************"
echo "*    create container with systemd in priviledged mode and start it    *"
echo "************************************************************************"
echo ""
echo ""

echo "buildah"
buildah build -t localhost/debian-arm -f Dockerfile .
echo ""
echo ""
echo "podman run"
podman run --systemd=always -td --name=debian-arm --network=host --arch=arm \
--entrypoint=/usr/bin/qemu-arm-static localhost/debian-arm -execve -0 /sbin/init /sbin/init 
echo ""
echo ""


# podman generate systemd --new --files -n debian-moode
# sudo cp /home/$USER/container-debian-moode.service /etc/systemd/system
# systemctl daemon-reload
# systemctl start container-debian-moode


sleep 2
# podman exec -ti debian-moode /bin/bash -c "ip addr show"
sleep 2

echo ""
echo "*********************************************"
echo "*        install vital dependecies          *"
echo "*********************************************"
echo ""
sleep 2

podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get update -y ; sleep 3 ; apt-get upgrade -y"
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils"
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt --fix-broken install -y"
echo ""
echo ""
# read -p "Press any key to continue... " -n1 -s

echo ""
echo ""
echo "Will change ssh port to 2222 to fix openssh"
echo ""
echo ""
sleep 1

podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config;"
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "systemctl restart sshd"


echo ""
echo "*********************************************"
echo "*        install moode player               *"
echo "*********************************************"
echo ""
sleep 1

podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash -"
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get update -y"
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install udisks nginx triggerhappy samba dnsmasq -y"
echo ""
echo ""
#read -p "Press any key to continue... " -n1 -s

podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install moode-player -y --fix-missing"
echo ""
echo ""
echo ""
echo "In general this long install return error, next move will try to fix this"
echo ""
echo ""
echo ""
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt --fix-broken install -y"
sleep 1
echo ""
echo ""
echo ""
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt-get install moode-player -y --fix-missing"
sleep 1
echo ""
echo ""
echo ""
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "apt upgrade -y"
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
systemctl start container-debian-moode

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
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "sudo sed -i 's/80 /8008 /g' /etc/nginx/sites-available/moode-http.conf"
podman exec -it debian-arm /usr/bin/qemu-arm-static -execve /bin/bash -c "systemctl restart nginx"

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


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
echo "*********************************************"
echo "*        install multiarch qemu layers      *"
echo "*********************************************"
echo ""
sleep 3

docker run --privileged --rm tonistiigi/binfmt --install all
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes # This step will execute the registering scripts

echo ""
echo "********************************************************************************************"
echo "*   Optional - If you want Moode to get an exlusive access to vital service MPD,CIFS,NFS   *"
echo "********************************************************************************************"
echo ""

#while true; do
#read -p "Do you want to proceed? note: Playing from volumio won't be possible anymore but it allow radios and MPD control from moode (y/n) " yn
#case $yn in 
#	[yY] ) echo ok, we will proceed;
  sudo systemctl stop mpd.service mpd.socket nfs-client.target smbd.service 
	sudo systemctl disable mpd.service mpd.socket nfs-client.target smbd.service 
	sudo systemctl mask mpd.service mpd.socket nfs-client.target smbd.service 
#		break;;
#	[nN] ) echo exiting...;
#		break;;
#	* ) echo invalid response;;
#esac
#done




echo ""
echo ""
echo "************************************************************************"
echo "*    create container with systemd in priviledged mode and start it    *"
echo "************************************************************************"
echo ""

docker create --name debian-moode --restart always -v /sys/fs/cgroup:/sys/fs/cgroup --cgroupns=host --tmpfs /tmp --tmpfs /run --tmpfs /run/lock --net host --privileged -e LANG=C.UTF-8 --cap-add=NET_ADMIN --security-opt seccomp:unconfined navikey/raspbian-bullseye /lib/systemd/systemd
docker container start debian-moode

echo ""
echo "*********************************************"
echo "*        install vital dependecies          *"
echo "*********************************************"
echo ""
sleep 3

docker exec -ti debian-moode /bin/bash -c "apt-get update -y ; sleep 3 ; apt-get upgrade -y"
docker exec -ti debian-moode /bin/bash -c "apt-get install -y curl sudo libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils nfs-common"
docker exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"

echo ""
echo ""
echo "Will change ssh port to 2222 to fix openssh"
echo ""
echo ""
sleep 2

docker exec -ti debian-moode /bin/bash -c "sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config;"
docker exec -ti debian-moode /bin/bash -c "systemctl restart sshd"


echo ""
echo "*********************************************"
echo "*        install moode player               *"
echo "*********************************************"
echo ""
sleep 5

docker exec -ti debian-moode /bin/bash -c "curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash -"
docker exec -ti debian-moode /bin/bash -c "apt-get update -y ; apt-get install moode-player -y --fix-missing"
echo ""
echo ""
# echo "In general this long install return error, next move will try to fix this"
echo ""


docker exec -ti debian-moode /bin/bash -c "apt --fix-broken install -y"
sleep 2
docker exec -ti debian-moode /bin/bash -c "apt-get install moode-player -y --fix-missing"
sleep 2
docker exec -ti debian-moode /bin/bash -c "apt upgrade -y"
#sleep 2
docker exec -ti debian-moode /bin/bash -c "exit"       

echo ""
echo "****************************************"
echo "*    restart moode player (host side)  *"
echo "****************************************"

docker container stop debian-moode
docker container start debian-moode

echo ""
echo ""
echo "***************************************"
echo "*    configure nginx (container side) *"
echo "***************************************"
echo ""
echo "Will change moode http port to 8008 to avoid conflict with volumio front"
echo ""
echo ""
sleep 2
docker exec -ti debian-moode /bin/bash -c "sudo sed -i 's/80 /8008 /g' /etc/nginx/sites-available/moode-http.conf"
docker exec -ti debian-moode /bin/bash -c "service restart nginx"

echo ""
echo "****************************"
echo "*    Access Moode web UI   *"
echo "****************************"
echo ""
echo "Your device will now restart"
echo ""
echo ""
echo "CTRL+CLIC on http://yourserverip:8008"
echo ""
echo "Enjoy"
# sudo reboot


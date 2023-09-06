# Moode_docker

This bash script will allow you to setup a full fontionnal moode-player OS in a multicarch docker environment
All the process is automated 
&nbsp;  &nbsp;  

# What you get 
```
  ###   is working
 - UI and artworks without any restriction ( First time it's slow when building library)
 - MPD access to host /mnt/partition
 - playing any codecs tested (flac, AAV, mp3)
 - Wifi, ethernet, bluetooth
 - Radios
 - Equalizer, parametric equalizer  
  
  ###   is not working
  - Camilla DSP
  - you tell me  
```
# Prerequisite

- Docker installed on your machine
- A terminal to ssh (my preference go to Mobaxterm)    
&nbsp;  &nbsp;  

# Installation

in a ssh terminal lauch following command
``` 
bash <(curl -Ls https://raw.githubusercontent.com/chourmovs/moode_docker/main/moode_docker.sh)

```

And follow the instructions...    
&nbsp;  &nbsp;  

# Troubleshoot

Q : My share can't mont &nbsp;  &nbsp;   
A : try to edit path manually in Library/host and remove any option in Library/advanced/mount options (leave it blank and save)

Q : Moode can't browse my mounted share  &nbsp; &nbsp;   
A : restart MPD in Configure/Audio/MPD section, then Configure/library/Music Database/Regenerate      

Q : Access moodeOS console   
A : in your host ssh console put <b>"sudo docker exec -ti debian-moode /bin/bash"</b>   

# Changelog
```
09.06.23 v1.0 initial release

```            
    

# To follow and discuss

https://chourmovs.wixsite.com/blog/en/post/install-moode-in-a-docker-container-on-volumio-primo-asus-tinkerboard-armv7l



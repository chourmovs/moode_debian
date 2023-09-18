ENV DEBIAN_FRONTEND noninteractive

#FROM docker.io/balenalib/armv7hf-debian as base
FROM docker.io/balenalib/raspberrypi3-debian as base
FROM docker.io/balenalib/raspberrypi3-debian
#FROM docker.io/balenalib/armv7hf-debian

COPY --from=base /bin/sh /bin/sh.real

RUN [ "cross-build-start" ]


RUN apt-get update \
    && apt-get install -y sudo systemd systemd-sysv \
    && sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config \
    && systemctl restart sshd \
    && curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash - \
    && apt-get update -y \
    && apt-get install -y udisks nginx triggerhappy samba dnsmasq \    
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Make sure systemd doesn't start agettys on tty[1-6].
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

RUN apt-get update \
     && apt-get install -y apt-utils  curl libxaw7 ssh libsndfile1 libsndfile1-dev cifs-utils apt-utils \
    && sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config \
    && systemctl restart sshd \
    && curl -1sLf  'https://dl.cloudsmith.io/public/moodeaudio/m8y/setup.deb.sh' | sudo -E distro=raspbian codename=bullseye arch=armv7hf bash - \
    && apt-get update -y \
    && apt-get install -y udisks nginx triggerhappy samba dnsmasq     

VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]


RUN [ "cross-build-end" ]

ENV DEBIAN_FRONTEND teletype

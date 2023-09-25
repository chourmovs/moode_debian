ENV DEBIAN_FRONTEND noninteractive

#FROM docker.io/balenalib/raspberrypi3-debian:latest as base
#FROM docker.io/balenalib/raspberrypi3-debian:latest
FROM docker.io/balenalib/raspberry-pi:bullseye as base
FROM docker.io/balenalib/raspberry-pi:bullseye 

COPY --from=base /bin/sh /bin/sh.real

RUN [ "cross-build-start" ]


RUN apt-get update \
    && apt-get install -y sudo systemd systemd-sysv \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean 

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Make sure systemd doesn't start agettys on tty[1-6].
RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

VOLUME  /sys/fs/cgroup
CMD ["/lib/systemd/systemd"]
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d

RUN [ "cross-build-end" ]

ENV DEBIAN_FRONTEND teletype

# sudo podman container stop -a && sudo podman container rm -a && sudo podman system prune -a -f && sudo podman volume prune -f


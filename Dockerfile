FROM ubuntu
MAINTAINER Jared H. Hudson <jhhudso@volumehost.com>

ENV UNAME steam

RUN dpkg --add-architecture i386
RUN apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes mesa-utils xauth kmod \
     wget gdebi-core pciutils usbutils dbus-x11 psmisc strace libdbus-1-3:i386 \
     libdbus-glib-1-2:i386 libnm-glib4:i386 libgl1-mesa-dri:i386 \
     libgl1-mesa-glx:i386 sudo pulseaudio-utils gdebi-core

RUN wget http://media.steampowered.com/client/installer/steam.deb && \
    DEBIAN_FRONTEND=noninteractive gdebi -n steam.deb
RUN wget https://download.nvidia.com/XFree86/Linux-x86_64/387.22/NVIDIA-Linux-x86_64-387.22.run
RUN chmod a+x NVIDIA-Linux-x86_64-387.22.run
RUN ./NVIDIA-Linux-x86_64-387.22.run --skip-module-unload \
    --no-kernel-module --no-x-check --silent

COPY pulse-client.conf /etc/pulse/client.conf

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    useradd -mU -u 1000 ${UNAME} && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio


# run
#CMD ["glxgears"]
CMD ["/bin/bash","-l"]

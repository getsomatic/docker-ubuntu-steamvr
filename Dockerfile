FROM ubuntu
MAINTAINER Jared H. Hudson <jhhudso@volumehost.com>

ENV UNAME steam

RUN dpkg --add-architecture i386
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes mesa-utils xauth kmod \
     wget gdebi-core pciutils usbutils dbus-x11 psmisc strace libdbus-1-3:i386 \
     libdbus-glib-1-2:i386 libnm-glib4:i386 libgl1-mesa-dri:i386 \
     libgl1-mesa-glx:i386 sudo pulseaudio-utils gdebi-core \
     libvulkan1 libvulkan1:i386

RUN wget http://media.steampowered.com/client/installer/steam.deb && \
    DEBIAN_FRONTEND=noninteractive gdebi -n steam.deb && rm steam.deb
RUN wget http://us.download.nvidia.com/tesla/410.79/NVIDIA-Linux-x86_64-410.79.run && \
    chmod a+x NVIDIA-Linux-x86_64-410.79.run && \
    ./NVIDIA-Linux-x86_64-410.79.run --skip-module-unload --no-kernel-module --no-x-check --silent && \
    rm ./NVIDIA-Linux-x86_64-410.79.run

COPY pulse-client.conf /etc/pulse/client.conf

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    useradd -mU -u 1000 ${UNAME} && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio

# Set up Steam
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p /home/steam/.local/share/Steam && \
    chown steam:steam -R /home/steam/.local/

# run
CMD ["/bin/bash","-l"]

FROM ubuntu
MAINTAINER Jared H. Hudson <jhhudso@volumehost.com>

ENV UNAME somatic

RUN dpkg --add-architecture i386
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes mesa-utils xauth kmod \
     wget gdebi-core pciutils usbutils dbus-x11 psmisc strace libdbus-1-3:i386 \
     libdbus-glib-1-2:i386 libgl1-mesa-dri:i386 \
     libgl1-mesa-glx:i386 sudo pulseaudio-utils gdebi-core \
     libvulkan1 libvulkan1:i386

RUN wget http://media.steampowered.com/client/installer/steam.deb && \
    DEBIAN_FRONTEND=noninteractive gdebi -n steam.deb && rm steam.deb

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-driver-510;
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libsdl2-dev libsdl2-2.0-0 lshw;

COPY pulse-client.conf /etc/pulse/client.conf

RUN echo "none x" >> /etc/security/capability.conf;

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    useradd -mU -u 1000 ${UNAME} && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    chown ${UID}:${GID} -R /home/${UNAME} && \
    gpasswd -a ${UNAME} audio

USER somatic

# Set up Steam
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
    mkdir -p /home/somatic/.local/share/Steam && \
    chown somatic:somatic -R /home/somatic/.local/

ENV VRCOMPOSITOR_LD_LIBRARY_PATH /home/somatic/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/

# run
CMD ["/bin/bash","-l"]


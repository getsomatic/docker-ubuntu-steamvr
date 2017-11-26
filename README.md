# Docker Ubuntu based SteamVR
An example of Steam and SteamVR working within a Ubuntu Docker container

[Docker Hub](https://hub.docker.com/r/jhhudso/docker-ubuntu-steamvr/)

## Building
```bash
git clone https://github.com/jhhudso/docker-ubuntu-steamvr
cd docker-ubuntu-steamvr
sudo ./buid.sh
```

## Running First time -- Setup Steam and SteamVR
```bash
./run_steam.sh
```
Accept EULA, login to steam, install SteamVR, run SteamVR, Setup VR, exit
SteamVR, exit Steam, exit container.
Whatever changes were made to the container during that run of SteamVR will be
committed to the image that subsequent runs will use.

## Explanation
TBD.

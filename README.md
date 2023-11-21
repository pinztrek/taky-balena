# taky-balena

TAKY is a lightweight TAK server that is in increasing usage. It is python code and is normally installed on a server and executed via systemd, etc. 

Since TAKY runs effectively on smaller SBC's like the Raspberry Pi, it's an execellent candidate for containerization, and specifically, treat it as a minimal touch IOT infrastructure device. 

Balena-cloud is a widely used method to containerize and manage fleets of IOT devices. 
*taky-balena* is a set of balena Dockerfile, docker_compose.yaml, and support scripts to allow TAKY to be executed and managed in a balena environment. 

## Development Status
- **v0.5 functional beta** Taky executes, and you can perform basic admin via takyctl using the ssh funcitonality of the balena dashboard.

## Getting Started
### get the docker-compose files:
- If you want to work with Balena directly: `git clone  https://github.com/pinztrek/taky-balena`
- But the easiest path is to create a balena fleet via:
[https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/pinztrek/taky-balena](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/pinztrek/taky-balena).
- Set up fleet variables for using the advanced tab (or later via balena dashboard):
    - **HOSTNAME** The name you want the TAKY instance to show up as in the server list
    - **PUBLICIP** The external IP you want the TAKY generated client packages to point to
    - **NOSSL** Define this as to true if you want TAKY to create server TCP config upon 1st run rather than SSL and use port 8087. Otherwise the default is to use SSL and port 8089. 

You most likely want to use SSL, but this capability allows us to start up as TCP, then upload datapackage with an existing TAKY config tree. 

- Via the balena taky-balena dashboard add a taky-balena device, burn the SD-card, and boot it up.  
    - Note: You will most likely want to tick the development mode to enable ssh
    - You will also need to set any wifi SSID's and passwords as needed

- Since it does not have a TAKY config it will create one, with or without SSL as defined by the NOSSL fleet or device variable

- The taky services will start, with taky cot on port 8087 or 8089, and taky_dps on 8443. 

- If you need to start over you can define **RESET** as true and it will rebuild config from scratch. 

## Once you are running
- **Generate a client package**
    - Access the balena dashboard for your device and ssh into the taky-cot service. (or ssh directly into the container if you know how)
    - Change to a known directory: `cd /data`
    - use *takyctl* to create a client package:
`takyctl -c /data/taky/taky.config build_client`
    - use scp or similar from another computer to download the package or mount the sdcard on a linux system and copy it off the data volume. I use scp (See below)

- You can also edit the config file as needed in /data/taky using either vi (real men) or nano. 

## Other notes
- **Moving Files** you can scp files in and out of the device:
    - Copy the taky data to a local directory:<br> 
`scp -r -P 22222 root@172.16.123.123:/mnt/data/docker/volumes/*/_data/taky .`
    - Download a client package using scp:<br> 
`scp -P 22222 root@172.16.123.123:/mnt/data/docker/volumes/*/_data/XYZ.zip .`
    - Copy a config tree to the taky data volume:<br> 
`scp -r -P 22222 taky root@172.16.123.123:/mnt/data/docker/volumes/*/_data/`

- **Firewall Considerations** If exposing taky via firewall to the Internet you will want to use high ports. The best method is to leave taky at 8089 and just map to something like 58089 or similar. Same for the 8443 data package. Even with SSL I noticed several explorer access on 8443 within minutes of starting up. If you do this you will need to edit your server entry advanced section to use the high port for cots. Likewise, if you remap the datapackage 8443 you have to go deeper in ATAK and override the 8443 port. This unfortunately applies to all servers, so is not ideal. I need to explore the "require client SSL" option in taky more. 

- **Memory Usage** When running on a Pi it seems to want about 380-450M of memory. This makes it usable (barely) on a Pi Zero 2W, and a plain Pi Zero W will not work without many changes as it can't do 64bit But does not have enough memory anyway. Pi 3B+ and Pi 4's work great. 
- **SD Card Size** You can probably get away with as small as 8GB, but I use 32GB's as they are now cheap, available, and allow room for data packages


## Objectives
- *Provide basic COT and data package functionality* **v0.5**
- *No mods to base TAKY code* **v0.5**
- *Zero config startup, work right out of the box as local taky node* **v0.5**
- *Capability to create taky client data packages* **v0.5**
- *Capability to override external host/FQDN after build using balena variables* **v0.5**
- *Capability to reset install after build either via:*
    - Removing taky config directory, forcing rerun of initial setup **v0.5**
    - Triggering delete and reconfig via balena variable **v0.5**
- Capability to upload a config archive and trigger overlay of the config via environment variable
    - Initial approach will be a takycfg.tar file in /data *in progress*
    - Long term approach will be to also leverage a admin generated data package uploaded via ATAK

## To-Do
- Revisit the dual stage build from Matthew-Beckett's approach as it's not really providing economy of images due to the need to add a shared lib in the run image. But... Balena caching is effectively providing the desired outcome as the same Dockerfile is used for both services. Only the entry point starting script is different. 
- Refine the capability to start-up a device from scratch, build a SSL config, and make it available for download. A device variable on the balena dashboard would be used to trigger this. 
- Develop capability to override SSL to TCP at startup to allow a machine to be temporarily run on TCP to allow connect and client package download. Again, triggered by a device variable on the balena dashboard. This will require adding an option to taky-cot to ignore the ssl setting in the config file


## Credits
*taky-balena* leveraged approaches and possible code fragments from a couple of different docker approaches for TAKY including:
- [https://github.com/Matthew-Beckett/taky](https://github.com/Matthew-Beckett/taky)
- Past versions of Dockerfiles in [https://github.com/tkuester/taky](https://github.com/tkuester/taky)


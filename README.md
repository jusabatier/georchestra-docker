# georchestra-docker

This project allow to setup a Georchestra instance via Docker's containers.

The Postgis database and LDAP directory are persistent, and the http proxy is nginx.

Learn more about docker : https://www.docker.com/, https://docs.docker.com/

## Install Docker

In order to install Docker, I used the last Ubuntu distribution (Trusty 14.04).

First install wget if not already done :
```
sudo apt-get update && sudo apt-get install wget
```

Get the latest Docker package : 
```
wget -qO- https://get.docker.com/ | sh
```

Verify docker is installed correctly : 
```
sudo docker run hello-world
```

But you can install it on a lot of others distribution, cf. https://docs.docker.com/installation/
If you have some problems Google is your friend ;)

Personally, I had to configure DNS for docker in order to have my containers connected to internet :

Open the /etc/default/docker file for editing and add a setting for Docker DNS :
```
DOCKER_OPTS="--dns 8.8.8.8 --dns <other DNS entries>"
```

And finally restart docker : 
```
sudo restart docker
```


# Some usefull commands for Docker

## Launch a bash in a running container

```
docker exec -t -i <container name> /bin/bash
```

## Stop all running containers

```
docker stop $(docker ps -a -q)
```

## Remove all containers

```
docker rm $(docker ps -a -q)
```

And to remove the linked volumes :

```
docker rm -v $(docker ps -a -q)
```

## See details abouts running containers

```
docker ps
```

# Some usefull commands for Docker-compose

## See light running containers infos

```
docker-compose ps
```

## Readme

This document provides with a small cluster of 4 node including one manager.


Init docker swarm
```
$ docker swarm init --advertise-addr 192.168.135.100
```

Join the swarm from all other nodes.
```
$ docker swarm join --token <SWARM-TOKEN> 192.168.135.100:2377
```

List all nodes
```
$ docker node ls
```

Create a new swarm service
```
docker service create --name gethostname --replicas=8 -p 5000:5000 gaumire/gethostname
```

This is a small docker app that returns the container hostname. `curl http://localhost:5000` should return the container hostname.

List all services
```
$ docker service ps gethostname
```

Scale services to zero
```
$ docker service scale gethostname=0
```

Scale services back to 8 or more
```
$ docker service scale gethostname=8
```

Check with curl on any of the nodes, you should be receiving 8 different container IDs.
```
$ curl http://localhost:5000
```

Run [docker swarm visualizer](https://github.com/dockersamples/docker-swarm-visualizer) on manager node. Access it at http://192.168.135.100:8080/. It should show you the list of nodes and services running there.
```
$ docker service create --name=visualizer -p 8080:8080 --constraint=node.role==manager --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock dockersamples/visualizer
```

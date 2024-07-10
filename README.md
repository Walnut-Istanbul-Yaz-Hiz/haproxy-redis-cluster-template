## HAProxy Redis Cluster Script

### Purpose
This script builds a **basic** Redis load balancer image for a Redis cluster using Docker and HAProxy.

### Author
walnut.ist

---

### Prerequisites
- Docker installed on your system.
- Basic knowledge of Docker commands and networking.

### Script Overview
This script performs the following tasks:
1. Creates a Docker network for the Redis cluster.
2. Runs six Redis instances on the created network.
3. Configures one Redis instance as the master and the others as slaves.
4. Runs a HAProxy container to load balance the Redis cluster.

### Script Details

#### Step 1: Create Docker Network
Creates a Docker network with a subnet that supports up to 16 IP addresses.

```sh
if [ ! "$(docker network ls | grep redis-cluster-net)" ]; then
    docker network create --subnet=10.0.0.0/28 redis-cluster-net
fi
```

#### Step 2: Run Redis Instances
Starts six Redis containers on the created network with specified IP addresses and ports.

```sh
docker run -d --name redis-master-1 --net redis-cluster-net --ip 10.0.0.2 -p 63791:6379 redis
docker run -d --name redis-slave-2 --net redis-cluster-net --ip 10.0.0.3 -p 63792:6379 redis
docker run -d --name redis-slave-3 --net redis-cluster-net --ip 10.0.0.4 -p 63793:6379 redis
docker run -d --name redis-slave-4 --net redis-cluster-net --ip 10.0.0.5 -p 63793:6379 redis
docker run -d --name redis-slave-5 --net redis-cluster-net --ip 10.0.0.6 -p 63793:6379 redis
docker run -d --name redis-slave-6 --net redis-cluster-net --ip 10.0.0.7 -p 63793:6379 redis
```

#### Step 3: Run HAProxy Load Balancer
Starts a HAProxy container configured to load balance the Redis cluster.

```sh
docker run -d --name redis-lb --net redis-cluster-net --ip 10.0.0.8 -p 6379:6379 --sysctl net.ipv4.ip_unprivileged_port_start=0 -v ${pwd}/haproxy:/usr/local/etc/haproxy:rw haproxy:lts
```

#### Step 4: Setup Redis Master and Slaves
Configures `redis-master-1` as the master and the rest as slaves.

```sh
docker exec -it redis-slave-2 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-3 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-4 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-5 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-6 bash -c "redis-cli slaveof 10.0.0.2 6379"
```

### Testing the Redis Cluster
Commands to test the Redis cluster (optional). you should run each command in a separate terminal.

```sh
docker exec -it redis-slave-2 bash -c "redis-cli subscribe chat"
docker exec -it redis-slave-3 bash -c "redis-cli subscribe chat"
docker exec -it redis-slave-4 bash -c "redis-cli subscribe chat"
docker exec -it redis-slave-5 bash -c "redis-cli subscribe chat"
docker exec -it redis-slave-6 bash -c "redis-cli subscribe chat"
docker exec -it redis-master-1 bash -c "redis-cli publish chat 'hello world'"
```

### Test via HAProxy
Test the Redis cluster via HAProxy.

start monitoring in docket container, you should run each command in a separate terminal.
```sh
docker exec -it redis-slave-2 bash -c "redis-cli monitor | grep chat"
docker exec -it redis-slave-3 bash -c "redis-cli monitor | grep chat"
docker exec -it redis-slave-4 bash -c "redis-cli monitor | grep chat"
docker exec -it redis-slave-5 bash -c "redis-cli monitor | grep chat"
docker exec -it redis-slave-6 bash -c "redis-cli monitor | grep chat"
docker exec -it redis-master-1 bash -c "redis-cli set chat 'hello world'"
```

you can see round robin load balancing in the logs.

```sh
redis-cli -h 127.0.0.1 -p 6379
> get chat
> get chat
> ...
```


### Usage
To run the script, ensure it is executable and run it in a shell.

```sh
chmod +x build.sh
./build.sh
```

### Notes
- Ensure you have the necessary permissions to create Docker networks and run Docker containers.
- Modify the script as needed to fit your specific use case or environment.
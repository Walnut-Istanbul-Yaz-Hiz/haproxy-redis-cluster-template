# Welcome to the build script for the haproxy redis cluster image.
# Purpose : Build a redis load balancer image for the redis cluster. 
# Anthor  : walnut.ist
# Date    : 2024-07-10


# Create a network for 2^(32-28) = 16 IPs
if [ ! "$(docker network ls | grep redis-cluster-net)" ]; then
    docker network create --subnet=10.0.0.0/28 redis-cluster-net
fi

# Run the redis cluster
docker run -d --name redis-master-1 --net redis-cluster-net --ip 10.0.0.2 -p 63791:6379 redis
docker run -d --name redis-slave-2 --net redis-cluster-net --ip 10.0.0.3 -p 63792:6379 redis
docker run -d --name redis-slave-3 --net redis-cluster-net --ip 10.0.0.4 -p 63793:6379 redis
docker run -d --name redis-slave-4 --net redis-cluster-net --ip 10.0.0.5 -p 63793:6379 redis
docker run -d --name redis-slave-5 --net redis-cluster-net --ip 10.0.0.6 -p 63793:6379 redis
docker run -d --name redis-slave-6 --net redis-cluster-net --ip 10.0.0.7 -p 63793:6379 redis

# Run the redis cluster load balancer
docker run -d --name redis-lb --net redis-cluster-net --ip 10.0.0.8 -p 6379:6379 --sysctl net.ipv4.ip_unprivileged_port_start=0 -v ${pwd}/haproxy:/usr/local/etc/haproxy:rw haproxy:lts

# Setup master : redis1 , slaves : redis2, redis3, redis4
docker exec -it redis-slave-2 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-3 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-4 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-5 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-6 bash -c "redis-cli slaveof 10.0.0.2 6379"

# README.md for more
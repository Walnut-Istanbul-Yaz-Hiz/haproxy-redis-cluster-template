# Welcome to the build script for the haproxy redis cluster image.
# Purpose : Build a redis load balancer image for the redis cluster. 
# Anthor  : walnut.ist
# Date    : 2024-07-10


# Create a network for 8 IPs
docker network create --subnet=10.0.0.0/29 redis-cluster-net


# Run the redis cluster
redis1 = $(docker run -d --name redis1 --net redis-cluster-net --ip 10.0.0.1 -p 63791:6379 redis)
redis2 = $(docker run -d --name redis2 --net redis-cluster-net --ip 10.0.0.2 -p 63792:6379 redis)
redis3 = $(docker run -d --name redis3 --net redis-cluster-net --ip 10.0.0.3 -p 63793:6379 redis)
redis4 = $(docker run -d --name redis4 --net redis-cluster-net --ip 10.0.0.4 -p 63794:6379 redis)

# Run the redis cluster load balancer
redis_lb = $(docker run -d --name redis-lb --net redis-cluster-net --ip 10.0.0.5 -p 6379:6379 --sysctl net.ipv4.ip_unprivileged_port_start=0 -v ./haproxy:/usr/local/etc/haproxy:rw haproxy:lts)
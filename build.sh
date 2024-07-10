# Welcome to the build script for the haproxy redis cluster image.
# Purpose : Build a redis load balancer image for the redis cluster. 
# Anthor  : walnut.ist
# Date    : 2024-07-10


# Create a network for 2^(32-28) = 16 IPs
if [ ! "$(docker network ls | grep redis-cluster-net)" ]; then
    docker network create --subnet=10.0.0.0/28 redis-cluster-net
fi

# Run the redis cluster
redis1=$(docker run -d --name redis1 --net redis-cluster-net --ip 10.0.0.2 -p 63791:6379 redis) 
redis2=$(docker run -d --name redis2 --net redis-cluster-net --ip 10.0.0.3 -p 63792:6379 redis)
redis3=$(docker run -d --name redis3 --net redis-cluster-net --ip 10.0.0.4 -p 63793:6379 redis)
redis4=$(docker run -d --name redis4 --net redis-cluster-net --ip 10.0.0.5 -p 63793:6379 redis)
redis5=$(docker run -d --name redis5 --net redis-cluster-net --ip 10.0.0.6 -p 63793:6379 redis)
redis6=$(docker run -d --name redis6 --net redis-cluster-net --ip 10.0.0.7 -p 63793:6379 redis)

# Run the redis cluster load balancer
redis_lb=$(docker run -d --name redis-lb --net redis-cluster-net --ip 10.0.0.8 -p 6379:6379 --sysctl net.ipv4.ip_unprivileged_port_start=0 -v ${pwd}/haproxy:/usr/local/etc/haproxy:rw haproxy:lts)

# Setup master : redis1 , slaves : redis2, redis3, redis4
docker exec -it redis2 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis3 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis4 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis5 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis6 bash -c "redis-cli slaveof 10.0.0.2 6379"

# Test the redis cluster
# docker exec -it redis2 bash -c "redis-cli subscribe chat"
# docker exec -it redis3 bash -c "redis-cli subscribe chat"
# docker exec -it redis4 bash -c "redis-cli subscribe chat"
# docker exec -it redis5 bash -c "redis-cli subscribe chat"
# docker exec -it redis6 bash -c "redis-cli subscribe chat"
# docker exec -it redis1 bash -c "redis-cli publish chat 'hello world'"
@echo off
REM Welcome to the build script for the haproxy redis cluster image.
REM Purpose : Build a redis load balancer image for the redis cluster. 
REM Author  : walnut.ist
REM Date    : 2024-07-10

REM Create a network for 2^(32-28) = 16 IPs
if not exist "$(docker network ls | findstr redis-cluster-net)" (
    docker network create --subnet=10.0.0.0/28 redis-cluster-net
)

REM Run the redis cluster
docker run -d --name redis-master-1 --net redis-cluster-net --ip 10.0.0.2 -p 63791:6379 redis
docker run -d --name redis-slave-2 --net redis-cluster-net --ip 10.0.0.3 -p 63792:6379 redis
docker run -d --name redis-slave-3 --net redis-cluster-net --ip 10.0.0.4 -p 63793:6379 redis
docker run -d --name redis-slave-4 --net redis-cluster-net --ip 10.0.0.5 -p 63794:6379 redis
docker run -d --name redis-slave-5 --net redis-cluster-net --ip 10.0.0.6 -p 63795:6379 redis
docker run -d --name redis-slave-6 --net redis-cluster-net --ip 10.0.0.7 -p 63796:6379 redis

REM Run the redis cluster load balancer
docker run -d --name redis-lb --net redis-cluster-net --ip 10.0.0.8 -p 6379:6379 --sysctl net.ipv4.ip_unprivileged_port_start=0 -v %cd%/haproxy:/usr/local/etc/haproxy:rw haproxy:lts

REM Setup slave nodes
docker exec -it redis-slave-2 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-3 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-4 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-5 bash -c "redis-cli slaveof 10.0.0.2 6379"
docker exec -it redis-slave-6 bash -c "redis-cli slaveof 10.0.0.2 6379"

REM Test the redis cluster
REM docker exec -it redis-slave-2 bash -c "redis-cli subscribe chat"
REM docker exec -it redis-slave-3 bash -c "redis-cli subscribe chat"
REM docker exec -it redis-slave-4 bash -c "redis-cli subscribe chat"
REM docker exec -it redis-slave-5 bash -c "redis-cli subscribe chat"
REM docker exec -it redis-slave-6 bash -c "redis-cli subscribe chat"
REM docker exec -it redis-master-1 bash -c "redis-cli publish chat 'hello world'"
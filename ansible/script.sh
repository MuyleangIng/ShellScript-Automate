#!/bin/bash
my_ip=$(curl -s ifconfig.me)
echo "My public IP address is: $my_ip"
# Get a list of running container IDs
container_ids=$(docker ps -q)

# Iterate over the container IDs and inspect each one
for container_id in $container_ids; do
    host_port=$(docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' "$container_id")
    echo "Container ID: $container_id, Host Port for Port 80: $host_port"
    echo "Container URL: $my_ip:$host_port"
done

# Replace 'your_command' with the actual command you want to run
touch  /shellscript/output.txt

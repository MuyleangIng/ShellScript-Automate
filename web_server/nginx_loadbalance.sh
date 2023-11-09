#!/bin/bash
echo "----------name for upstream--------------"
read -p "Enter your upsteam : " backend
echo "----------Enter server1 & port1--------------"
read -p "Enter server1: " server1
read -p "Enter port1: " port1
echo "----------Enter server2 & port2--------------"
read -p "Enter server2: " server2
read -p "Enter port2: " port2
echo "Write full domain name"
read dns
echo "Enter the desired NGINX configuration file name (e.g., my_website):"
read nginxConfigName

# Check for empty input
if [ -z "$server1" ] || [ -z "$port1" ] || [ -z "$server2" ] || [ -z "$port2" ] || [ -z "$dns" ] || [ -z "$nginxConfigName" ]; then
    echo "One or more fields were left empty. Exiting."
    exit 1
fi

nginxConfigDir="/etc/nginx/sites-available"
nginxConfigPath="$nginxConfigDir/$nginxConfigName"

# Check if the configuration file already exists
if [ -e "$nginxConfigPath" ]; then
    echo "Configuration file already exists. Choose a different name."
    exit 1
fi

# Generate the Nginx configuration
nginxConfigContent="
upstream $backend {
    server $server1:$port1;
    server $server2:$port2;
}
server {
    listen 80;
    server_name $dns;

    location / {
        proxy_pass http://$backend;
    }
}"

# Create the NGINX configuration file
echo "$nginxConfigContent" > "$nginxConfigDir/$nginxConfigName"

# Create a symbolic link to enable the configuration
sudo ln -s "$nginxConfigDir/$nginxConfigName" "/etc/nginx/sites-enabled/$nginxConfigName"

# Reload NGINX to apply the changes
sudo systemctl reload nginx  # Use 'service nginx reload' on some systems

echo "NGINX configuration updated with server_name: $dns and container port: $containerPort."
echo "NGINX configuration file created: $nginxConfigDir/$nginxConfigName."
echo "Symbolic link created in /etc/nginx/sites-enabled/$nginxConfigName."

# Run Certbot after NGINX configuration is updated and container is ready
certbot --nginx -d "$dns" --non-interactive

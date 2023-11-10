#!/bin/bash
echo "----------name for upstream--------------"
read -p "Enter your upsteam : " backend
echo "----------Enter server1 & port1--------------"
read -p "Enter server1: " server1
read -p "Enter port1: " port1
echo "----------Enter server2 & port2--------------"
read -p "Enter server2: " server2
read -p "Enter port2: " port2
echo "------------------------"
echo "please input ip address 188.166.191.62 "
while true; do
  read -p "Enter ipaddress: " ipaddress
  if [ -n "$ipaddress" ] ; then
    # Both inputs provided, exit the loop
    break
  else
    echo " inputs are required. Please try again."
  fi
done
echo "You entered ip address : $ipaddress"
#input domain name
subdomain="automatex-$(date +%s)"
curl -u 'muyleanging:c8c2397f4a299ed82757ff33c4326a07403586c1' 'https://api.name.com/v4/domains/sen-pai.live/records' -X POST -H 'Content-Type: application/json' --data '{"host":"'"$subdomain"'","type":"A","answer":"'"$ipaddress"'","ttl":300}'
# Read the desired NGINX configuration file name
echo "------------------------"
echo "Enter the desired NGINX configuration file name (e.g., my_website):"
while true; do
  read -p "Enter directory for nginx : " nginxConfigName
  if [ -n "$nginxConfigName" ] ; then
    # Both inputs provided, exit the loop
    break
  else
    echo " inputs are required. Please try again."
  fi
done
echo "Here is you file site-aviable: $nginxConfigName"

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
    server_name $subdomain.sen-pai.live;

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

echo "NGINX configuration updated with server_name: $subdomain.sen-pai.live and container port: $containerPort."
echo "NGINX configuration file created: $nginxConfigDir/$nginxConfigName."
echo "Symbolic link created in /etc/nginx/sites-enabled/$nginxConfigName."

# Run Certbot after NGINX configuration is updated and container is ready
if certbot --nginx -d "$subdomain.sen-pai.live" --non-interactive; then
    echo "Certbot successful."
    # Send a success message to Telegram with the domain
    #-1002078205340
    curl -s -X POST https://api.telegram.org/bot6678469501:AAGO8syPMTxn0gQGksBPRchC-EoC6QRoS5o/sendMessage -d chat_id=1162994521 -d text="                             
                ……….
            ……………….......
        ……       ✨       …
    …    ✨              ✨ ….
  ……           𝐜𝐨𝐧𝐠𝐫𝐚𝐭𝐳         ……
………        👏    🎉   👍        ………
  ……   ✨     ◝(ᵔᵕᵔ)◜     ✨  ……
    << $subdomain.sen-pai.live >>
                              …….
        ……        ✨     ….
                ……………....
                 ……."
else
    echo "Certbot failed."
    # Send an error message to Telegram with the domain
    curl -s -X POST https://api.telegram.org/bot6678469501:AAGO8syPMTxn0gQGksBPRchC-EoC6QRoS5o/sendMessage -d chat_id=1162994521 -d text="Certbot failed for domain: $subdomain.sen-pai.live."
fi



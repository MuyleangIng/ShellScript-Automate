#!/bin/bash

# Jenkins job details
echo "Enter the Jenkins job to trigger: "
jobName="frontend/deployNextjs"
echo "Triggering the $jobName job"

# Jenkins server authentication
user="admin"
passwd="11456d3775f4cdcdae349da61e44fac187"
url="http://188.166.191.62:8085/"

# Prompt the user for parameter values
echo "Enter 'y' for 'true' or 'n' for 'false' for BUILD_DOCKER:"
read -p "y or n: " input

if [ "$input" = "y" ]; then
    BUILD_DOCKER=true
elif [ "$input" = "n" ]; then
    BUILD_DOCKER=false
else
    echo "Invalid input. Please enter 'y' for 'true' or 'n' for 'false."
    # Handle the case where the user enters an invalid input or any other necessary action.
fi
echo "------------------------"
echo "Enter 'y' for 'true' or 'n' for 'false' for DOCKER_DEPLOY:"
read -p "y or n: " input

if [ "$input" = "y" ]; then
    DOCKER_DEPLOY=true
elif [ "$input" = "n" ]; then
    DOCKER_DEPLOY=false
else
    echo "Invalid input. Please enter 'y' for 'true' or 'n' for 'false."
    # Handle the case where the user enters an invalid input or any other necessary action.
fi
# echo "------------------------"
# echo "Enter 'production=master', 'staging=main','development'for branch:"
# read -p "Enter 'production', 'staging': " TEST_CHOICE
echo "------------------------"
echo "Choose a branch: 1. Production (master) 2. Staging (main)"
echo "1. Production"
echo "2. Staging"
read -p "Enter your choice (1 or 2): " branch

if [ "$branch" = "1" ]; then
  TEST_CHOICE="production"
elif [ "$branch" = "2" ]; then
  TEST_CHOICE="staging"
else
  echo "Invalid choice. Please enter 1 for Production or 2 for Staging."
  exit 1
fi

echo "Selected branch: $TEST_CHOICE"

echo "------------------------"
echo "Enter your registry name ex muyleangin or nexus registry"
while true; do
  read -p "Enter your registry: " REGISTRY_DOCKER
  if [ -n "$REGISTRY_DOCKER" ] ; then
    # Both inputs provided, exit the loop
    break
  else
    echo " inputs are required. Please try again."
  fi
done
echo "You entered Image Name: $REGISTRY_DOCKER"


echo "------------------------"
echo "Enter your image name ex: react or next ......"
while true; do
  read -p "Enter your images name: " BUILD_CONTAINER_NAME
  if [ -n "$BUILD_CONTAINER_NAME" ] ; then
    # Both inputs provided, exit the loop
    break
  else
    echo " inputs are required. Please try again."
  fi
done
echo "You entered Image Name: $BUILD_CONTAINER_NAME"

echo "------------------------"
echo "Docker tag ex:  1.1 or latest=default"
while true; do
  read -p "Enter docker_tag : " DOCKER_TAG
  if [ -n "$DOCKER_TAG" ] ; then
    # Both inputs provided, exit the loop
    break
  else
    echo " inputs are required. Please try again."
  fi
done
echo "You entered Image Name: $DOCKER_TAG"

echo "------------------------"
echo "Container Name for specific docker"
while true; do
  read -p "Enter container_name: " CONTAINER_NAME
  if [ -n "$CONTAINER_NAME" ] ; then
    # Both inputs provided, exit the loop
    break
  else
    echo " inputs are required. Please try again."
  fi
done
echo "You entered Image Name: $CONTAINER_NAME"

echo "------------------------"
echo "Enter REPO_URL:  ex: https://gitlab.com/MuyleangIng1/reactjs"
while true; do
  read -p "Enter your url git : " REPO_URL
  if [ -n "$REPO_URL" ] ; then
    # Both inputs provided, exit the loop
    break
  else
    echo " inputs are required. Please try again."
  fi
done
echo "You entered Image Name: $REPO_URL"

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

# Input Domain name
# echo "------------------------"
# echo "Enter dns:  ex: sen-pai.live"
# while true; do
#   read -p "Enter your Domain Name : " dns
#   if [ -n "$dns" ] ; then
#     # Both inputs provided, exit the loop
#     break
#   else
#     echo " inputs are required. Please try again."
#   fi
# done
# echo "You entered Image Name: $dns"
subdomain="ft-$(date +%s)"
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


# Trigger the Jenkins job with user-defined environment variables

java -jar jenkins-cli.jar -auth $user:$passwd -s $url -webSocket build -v \
    -p BUILD_DOCKER=$BUILD_DOCKER \
    -p DOCKER_DEPLOY=$DOCKER_DEPLOY \
    -p TEST_CHOICE=$TEST_CHOICE \
    -p REGISTRY_DOCKER="$REGISTRY_DOCKER" \
    -p BUILD_CONTAINER_NAME="$BUILD_CONTAINER_NAME" \
    -p CONTAINER_NAME="$CONTAINER_NAME" \
    -p DOCKER_TAG="$DOCKER_TAG"\
    -p REPO_URL="$REPO_URL" \
    $jobName


#!/bin/bash

nginxConfigDir="/etc/nginx/sites-available"

# Function to check if the container is running
wait_for_container() {
    while true; do
        if docker inspect --format='{{.State.Running}}' "$CONTAINER_NAME" | grep -q "true"; then
            echo "Container $CONTAINER_NAME is running and ready."
            break
        fi
        echo "Waiting for container $CONTAINER_NAME to be ready..."
        sleep 5  # Adjust the sleep interval as needed
    done
}

# Wait for the container to be ready
wait_for_container

# Get the container's mapped port
containerPort=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "3000/tcp") 0).HostPort}}' "$CONTAINER_NAME")

# Generate the NGINX configuration dynamically with the updated port
nginxConfigContent="
server {
    listen 80;
    server_name $subdomain.sen-pai.live;

    location / {
        proxy_pass http://$ipaddress:$containerPort;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
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


display_table() {
    printf "%-30s | %s\n" "Domain" "Container Name"
    printf "%-30s-+-%s\n" "---------------------------" "---------------------------"
    printf "%-30s | %s\n" "https://$subdomain.sen-pai.live" "$CONTAINER_NAME"
    # Add more rows as needed, dynamically or statically
}

# Calling the function to display the table
display_table
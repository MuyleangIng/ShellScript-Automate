#!/bin/bash

# Jenkins job details
echo "Enter the Jenkins job to trigger: "
read jobName
echo "Triggering the $jobName job"

# Jenkins server authentication
user="admin"
passwd="11456d3775f4cdcdae349da61e44fac187"
url="http://188.166.191.62:8085/"

# Prompt the user for parameter values
echo "Enter 'true' or 'false' for BUILD_DOCKER:"
read BUILD_DOCKER
echo "------------------------"
echo "Enter 'true' or 'false' for DOCKER_DEPLOY:"
read DOCKER_DEPLOY
echo "------------------------"
echo "Enter 'production', 'staging','development'for TEST_CHOICE:"
read TEST_CHOICE

# Prompt the user for environment variable values
echo "Enter REGISTRY_DOCKER:"
read REGISTRY_DOCKER
echo "------------------------"
echo "Enter BUILD_CONTAINER_NAME:"
read BUILD_CONTAINER_NAME

echo "------------------------"
echo "Enter DOCKER_TAG:"
read DOCKER_TAG

echo "------------------------"
echo "Container Name:"
read CONTAINER_NAME

echo "------------------------"
echo "Enter REPO_URL:"
read REPO_URL

echo "------------------------"
echo "Write full domain name"
read dns
# Read the desired NGINX configuration file name
echo "Enter the desired NGINX configuration file name (e.g., my_website):"
read nginxConfigName

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
containerPort=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' "$CONTAINER_NAME")

# Generate the NGINX configuration dynamically with the updated port
nginxConfigContent="
server {
    listen 80;
    server_name $dns;

    location / {
        proxy_pass http://localhost:$containerPort;
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

echo "NGINX configuration updated with server_name: $dns and container port: $containerPort."
echo "NGINX configuration file created: $nginxConfigDir/$nginxConfigName."
echo "Symbolic link created in /etc/nginx/sites-enabled/$nginxConfigName."

# Run Certbot after NGINX configuration is updated
certbot --nginx -d "$dns" --non-interactive

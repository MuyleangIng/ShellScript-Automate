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

echo "Enter 1 to input a subdomain, 2 to auto-generate, or press Enter to skip:"
echo "1. subdomain"
echo "2. auto-generate"
read -p "Enter your choice (1 or 2): " option
if [ "$option" = "1" ]; then
  echo "Enter your subdomain"
  while true; do
    read -p "Enter subdomain: " subdomain
    if [ -n "$subdomain" ]; then
      # User provided a subdomain, exit the loop
      break
    else
      echo "Input is required. Please try again."
    fi
  done
  echo "Your domain name: $subdomain"
elif [ "$option" = "2" ]; then
  subdomain="automatex-$(date +%s)"
  echo "Auto-generated subdomain: $subdomain"
else
  echo "No action taken. Proceeding without setting a custom subdomain."
fi

#input domain name
curl -u 'muyleanging:c8c2397f4a299ed82757ff33c4326a07403586c1' 'https://api.name.com/v4/domains/sen-pai.live/records' -X POST -H 'Content-Type: application/json' --data '{"host":"'"$subdomain"'","type":"A","answer":"'"$ipaddress"'","ttl":300}'
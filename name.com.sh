


subdomain="automatex-$(date +%s)"
curl -u 'muyleanging:c8c2397f4a299ed82757ff33c4326a07403586c1' 'https://api.name.com/v4/domains/sen-pai.live/records' -X POST -H 'Content-Type: application/json' --data '{"host":"'"$subdomain"'","type":"A","answer":"188.166.191.62","ttl":300}'
#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# This moves the script's context to its own folder
cd "$(dirname "$0")"

# This loads the env variables
source .env

echo 'Updating DNS to redirect to current IP ...'

[ -z "$ACCOUNT_ID" ] && echo "Error: Could not get Account ID from .env" && exit 1
echo 'Account OK'
[ -z "$DOMAIN_NAME" ] && echo "Error: Could not get Domain Name from .env" && exit 1
echo 'Domain OK'
[ -z "$CLOUDFLARE_API_TOKEN" ] && echo "Error: Could not get Cloudflare API Token from .env" && exit 1
echo 'Token OK'

RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
	-H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
	-H "Content-Type: application/json" | jq -r '.result[0].id')

[ -z "$RECORD_ID" ] && echo "Error: Could not get Record ID" && exit 1
echo "Record ID OK"

MY_IP=$(curl -s https://ifconfig.me)

[ -z "$MY_IP" ] && echo "Error: Could not get IP" && exit 1
echo "IP OK"

curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
	-H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
	-H "Content-Type: application/json" \
	--data "{
		\"content\": \"$MY_IP\",
		\"ttl\": 1,
		\"proxied\": false
	}"

echo 'Done'
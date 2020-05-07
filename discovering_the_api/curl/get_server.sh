#!/bin/bash

method="GET"
endpoint="ecs.eu-west-0.prod-cloud-ocb.orange-business.com"
apipath="/v2/"$OS_PROJECT_ID"/servers"
uricall="https://$endpoint$apipath"

#call to get token first
uriToken="${OS_AUTH_URL}/auth/tokens"
export token="$(curl -s -i -k -H "Content-Type: application/json" -X POST -d '{"auth":{"identity": {"methods":["password"], "password":{"user":{"name":"'$OS_USERNAME'","password":"'$OS_PASSWORD'","domain":{"id":"'$OS_USER_DOMAIN_ID'"}}}},"scope":{"project": {"name":"'$OS_PROJECT_NAME'"}}}}' $uriToken | awk '/X-Subject-Token/ {print $2}')"

#call to API
curl -k -H "Content-Type: application/json" -H "X-Auth-Token: ${token}" -X $method $uricall

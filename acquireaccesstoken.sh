#!/bin/bash

#Update these values for IDCS tenant/client being used

clientId="<client ID>"
clientSecret="<client secret>"
oauthService="<oauth service>"

grantType="client_credentials"
scope="urn:opc:idm:__myscopes__"

#combine the clientId and client Secret and encode them in base64 formatting
identity=`echo -n "${clientId}:${clientSecret}"|base64`

#Call webservice to get access token and parse out value of access token from JSON returned by web service
$token=`curl -s -k --noproxy ${oauthService} -H \"Authorization: Basic ${identity}\" -H \"Content-Type: application/x-www-form-urlencoded;charset=UTF-8\" --request POST https://${oauthService}/oauth2/v1/token -d \"grant_type=${grantType}&scope=${scope}\"" | python -c 'import json,sys;obj=json.load(sys.stdin);print (obj["access_token"])'`

echo $token

#!/bin/bash

# 华为云账号，不是email
HEC_USER_NAME=''
# 华为云密码
HEC_USER_PASSWD=''

# Region&Endpoints, 
# 具体定义请参考:http://developer.hwclouds.com/endpoint.html
HEC_REGION='cn-north-1'
HEC_IAM_ENDPOINT='https://iam.cn-north-1.myhwclouds.com'
HEC_ECS_ENDPOINT='https://ecs.cn-north-1.myhwclouds.com'
HEC_VPC_ENDPOINT='https://vpc.cn-north-1.myhwclouds.com'

AUTH_PARAMS='{
  "auth": {
    "identity": {
      "methods": [
        "password"
      ],
      "password": {
        "user": {
          "name": '"\"$HEC_USER_NAME\""',
          "password": '"\"$HEC_USER_PASSWD\""',
          "domain": {
            "name": '"\"$HEC_USER_NAME\""'
          }
        }
      }
    },
   "scope": {
      "project": {
        "name": '"\"$HEC_REGION\""'
      }
    }
  }
}'

# Request for token and tanent id
curl -i -X POST ${HEC_IAM_ENDPOINT}/v3/auth/tokens -H 'content-type: application/json' -d "$AUTH_PARAMS" > /tmp/hec_auth_res && {
    # Retrieve token by account username and password      
    TOKEN=`cat /tmp/hec_auth_res | grep "X-Subject-Token"| awk '{print$2}'`

    # Retrieve tanent id(project id)
    PROJECT_ID=`tail -n 1 /tmp/hec_auth_res|python -c 'import json,sys;print json.load(sys.stdin)["token"]["project"]["id"]'`

    # Request for all floating ips 
    curl -s -X GET ${HEC_VPC_ENDPOINT}/v2.0/floatingips -H "X-Auth-Token:${TOKEN}" | python -mjson.tool

    # Retrieve mapping between floating(public) ips and fixed(internal) ips
    IPS_MAPPING=`curl -s -X GET ${HEC_VPC_ENDPOINT}/v2.0/floatingips -H "X-Auth-Token:${TOKEN}" | python -c 'import json,sys; print "\n".join([x["fixed_ip_address"]+":"+x["floating_ip_address"] for x in json.load(sys.stdin)["floatingips"]])'`
    for MAPPING in $IPS_MAPPING; do
        # Annotate accessIPv4 attr to vm instance 
        FIXED_IP=`echo $MAPPING | awk -F ':' '{print $1}'`
        FLOAT_IP=`echo $MAPPING | awk -F ':' '{print $2}'`
        SERVER_ID=`curl -s -X GET ${HEC_ECS_ENDPOINT}/v2/${PROJECT_ID}/servers/detail?ip=$FIXED_IP -H "X-Auth-Token:${TOKEN}" | python -c 'import json,sys;print json.load(sys.stdin)["servers"][0]["id"]'`
        SERVER_PARAMS='{
            "server": {
                "accessIPv4": '"\"$FLOAT_IP\""'
            }
        }'
        curl -s -X PUT ${HEC_ECS_ENDPOINT}/v2/${PROJECT_ID}/servers/$SERVER_ID -d "$SERVER_PARAMS" -H "X-Auth-Token:${TOKEN}" | python -mjson.tool
    done

    echo
    echo
    echo "============================"
    echo
    echo
    # Retrieve all vms, which should have floating ip included.
    curl -s -X GET ${HEC_ECS_ENDPOINT}/v2/${PROJECT_ID}/servers/detail -H "X-Auth-Token:${TOKEN}" | python -mjson.tool
}

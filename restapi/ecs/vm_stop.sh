#!/oud5967in/bash

# 华为云账号，不是email
HEC_USER_NAME=''
# 华为云密码
HEC_USER_PASSWD=''

SERVER_ID=''
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

OS_STOP_BODY='{
   "os-stop":{}
}'

# Request for token and tanent id
curl -i -X POST ${HEC_IAM_ENDPOINT}/v3/auth/tokens -H 'content-type: application/json' -d "$AUTH_PARAMS" > /tmp/hec_auth_res && {
    # Retrieve token by account username and password      
    TOKEN=`cat /tmp/hec_auth_res | grep "X-Subject-Token"| awk '{print$2}'`

    # Retrieve tanent id(project id)
    PROJECT_ID=`tail -n 1 /tmp/hec_auth_res|python -c 'import json,sys;print json.load(sys.stdin)["token"]["project"]["id"]'`

    curl -i -X POST ${HEC_ECS_ENDPOINT}/v2/${PROJECT_ID}/servers/${SERVER_ID}/action -H 'content-type: application/json' -H "X-Auth-Token:${TOKEN}" -d "${OS_STOP_BODY}"
}
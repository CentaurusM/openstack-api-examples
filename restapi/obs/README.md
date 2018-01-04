# How to Manage HuaweiCLOUD OBS with s3cmd

## Install s3cmd

``` 
# Ubuntu
apt-get install s3cmd

# Centos
yum install s3cmd

```
## Configuration

```
s3cmd --configre # generate a config file in ~/.s3cmdcfg

```
modify the follwing attributes of config file
```
[default]
access_key = **************************
bucket_location = cn-north-1
host_base = obs.cn-north-1.myhwclouds.com
host_bucket = %(bucket)s.obs.cn-north-1.myhwclouds.com
secret_key = ***********************************

```

s3cmd ls

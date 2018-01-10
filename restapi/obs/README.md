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

## s3cmd examples

You can increase the level of verbosity with -v option and if you're really keen to know what the program does under its bonet run it with -d to see all 'debugging' output.

```
# List all buckets
s3cmd ls

# make a bucket
s3cmd mb s3://my-new-bucket-name

# List the contents of the bucket
s3cmd ls s3://my-bucket

# Upload a file into the bucket
s3cmd put file-* s3://logix.cz-test/ # multiple files
s3cmd put addressbook.xml s3://logix.cz-test/addrbook.xml
s3cmd put --acl-public --guess-mime-type storage.jpg s3://logix.cz-test/storage.jpg #with ACL

# Get the file
s3cmd get s3://logix.cz-test/addrbook.xml addressbook-2.xml

# Clean up: delete the object and remove the bucket
# delete the objects
s3cmd del s3://logix.cz-test/addrbook.xml s3://logix.cz-test/storage.jpg
# can only remove empty buckets
s3cmd rb s3://logix.cz-test






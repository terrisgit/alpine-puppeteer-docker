#! /bin/sh

# Optionally add AWS credentials
# mkdir .aws ; cp ~/.aws/* .aws

# This is just an example. If you are will probably need to specify a particular
# group id at a minimum. These settings are especially important if you are using
# Docker volumes.

docker build --build-arg USERID=$UID --build-arg GROUPID=$GROUPS -t terrisgit-alpine-puppeteer -f Dockerfile .


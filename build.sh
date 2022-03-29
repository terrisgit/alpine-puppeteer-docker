#! /bin/sh

mkdir .aws
cp ~/.aws/* .aws

docker build --build-arg UID=$UID --build-arg GID=$GROUPS -t terrisgit-alpine-puppeteer -f Dockerfile .

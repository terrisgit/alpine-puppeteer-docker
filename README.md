# puppeteer-alpine-docker-aws
Use Puppeteer in a Docker container using Alpine Linux with a ~/.aws directory

## Requirements

- Docker version 20 or later

## Dockerfile Arguments

- GROUPID - Defaults to 1000
- USERID - Defaults to 1000

## Building the Image

1. Modify build.sh per your needs
2. `build.sh`

## Running a Shell in the Container

`docker run -it terrisgit-alpine-puppeteer ash`

In the shell, run 'chromium-browser --version'.
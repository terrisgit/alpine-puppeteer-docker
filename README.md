# puppeteer-alpine-docker-aws
Use Puppeteer in a Docker container using Alpine Linux with a ~/.aws directory

## Requirements

- This does not work on MacOS with Apple processors! Even with `--platform=linux,` Chromium crashes upon starting with an error about ptrace

## Dockerfile Arguments

- GROUPID - Defaults to 1000
- USERID - Defaults to 1000

## Building the Image

Modify build.sh per your needs and run it

## Running a Shell in the Container

`docker run --init --shm-size=1gb -it terrisgit-alpine-puppeteer ash`

In the shell, try running 'chromium-browser'

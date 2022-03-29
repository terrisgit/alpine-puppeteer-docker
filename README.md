# puppeteer-alpine-docker-aws
Use Puppeteer in a Docker container using Alpine Linux with a ~/.aws directory

## Requirements

- This does not work on MacOS with Apple processors! Even with `--platform=linux,` Chromium crashes upon starting with an error about ptrace

## Dockerfile Arguments

- GID - Defaults to 1000
- UID - Defaults to 1000

## How to Use

- Modify build.sh per your needs and run it
- 

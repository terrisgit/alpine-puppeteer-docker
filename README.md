# puppeteer-alpine-docker

Use Puppeteer in a Docker container with everything you need to create high-quality PDF screenshots.

## Retrieving the version of Chromium

```sh
docker build .
docker run -it container_id chromium-browser --version
```
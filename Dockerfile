# See https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md#tips
#
# This container run with the following "docker run" flags:
# --init --shm-size=1gb
#
# Dockerfile arguments:
# USERID - Defaults to 1000
# GROUPID - Defaults to USERID

FROM alpine

ARG USERID=1000
ARG GROUPID=$USERID

RUN apk add --no-cache \
  chromium \
  nss \
  freetype \
  harfbuzz \
  ca-certificates \
  ttf-freefont \
  nodejs \
  npm

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true 
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN ln -s $PUPPETEER_EXECUTABLE_PATH /usr/bin/google-chrome-unstable

# Copy all files in all directories except those specified in .dockerignore
WORKDIR /app
COPY . /app

# Add user and group to avoid needing --no-sandbox
ENV USERID=$USERID
ENV GROUPID=$GROUPID

RUN addgroup -g $GROUPID -S appuser \
  && adduser -u $USERID -S -G appuser appuser \
  && mkdir -p /home/appuser/Downloads \
  && chown -R appuser:appuser /app \
  && chown -R appuser:appuser /home/appuser

USER appuser

# Add this to specify AWS credentials
# RUN mv /app/.aws /home/appuser

RUN npm i --only=production

RUN rm -rf /tmp/*

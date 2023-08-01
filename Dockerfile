################################################################################
# Dockerfile for running Puppeteer under Alpine.
#
# 🐋 Dockerfiles 🐋
# This Dockerfile: https://github.com/terrisgit/alpine-puppeteer-docker/blob/main/Dockerfile
# https://stackoverflow.com/questions/66512149/headless-chromium-in-ubuntu-docker-container
# https://github.com/MontFerret/chromium 
# https://github.com/Yelp/dumb-init
# https://github.com/tkp1n/chromium-ci/blob/master/Dockerfile
# https://github.com/Zenika/alpine-chrome/blob/master/Dockerfile
# https://simpleit.rocks/linux/ubuntu/fixing-common-google-chrome-gpu-process-error-message-in-linux
#
# 🦄 Puppeteer 🦄
# https://apitemplate.io/blog/tips-for-generating-pdfs-with-puppeteer/
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md
# https://www.koyeb.com/tutorials/deploy-a-web-scraper-using-puppeteer-node-and-docker
#
# 🎨 Chromium Versions 🎨
# https://pptr.dev/chromium-support
# https://pkgs.alpinelinux.org/packages?name=chromium&branch=edge&repo=&arch=x86_64
#
# ️🅰️ ️Web Fonts 🅰️
# The fonts installed by this Dockerfile are probably redundant.
# Recommended for pixel-perfect PDFs:
# https://unix.stackexchange.com/questions/438257/how-to-install-microsoft-true-type-font-on-alpine-linux
# https://github.com/alpaca-tc/puppeteer-pdf-generator/blob/master/Dockerfile
#
# 🚥 Recommended Chromium Switches 🚥
# https://peter.sh/experiments/chromium-command-line-switches
# --autoplay-policy=user-gesture-required
# --disable-background-networking
# --disable-background-timer-throttling
# --disable-backgrounding-occluded-windows
# --disable-breakpad
# --disable-client-side-phishing-detection
# --disable-component-update
# --disable-default-apps
# --disable-device-discovery-notifications
# --disable-domain-reliability
# --disable-extensions
# --disable-features=AudioServiceOutOfProcess
# --disable-features=IsolateOrigins
# --disable-gpu
# --disable-hang-monitor
# --disable-infobars
# --disable-ipc-flooding-protection
# --disable-notifications
# --disable-offer-store-unmasked-wallet-cards
# --disable-popup-blocking
# --disable-print-preview
# --disable-prompt-on-repost
# --disable-renderer-backgrounding
# --disable-setuid-sandbox
# --disable-site-isolation-trials
# --disable-software-rasterizer
# --disable-speech-api
# --disable-sync
# --hide-scrollbars
# --ignore-gpu-blacklist
# --metrics-recording-only
# --mute-audio
# --no-default-browser-check
# --no-first-run
# --no-pings
# --no-sandbox
# --no-zygote
# --password-store=basic
# --use-fake-device-for-media-stream
# --use-fake-ui-for-media-stream
# --use-gl=swiftshader
# --use-mock-keychain

ARG REPO=node:20-alpine
FROM $REPO

################################################################################
# Environment variables
ENV FONT_DIR=/usr/share/fonts
#
# Tell Puppeteer to not install Chrome. It's installed via APK.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
#
# Where is Chromium?
ENV CHROME_PATH=/usr/lib/chromium/
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
################################################################################

RUN apk update
RUN apk upgrade --no-cache

RUN echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
  && echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories 

RUN apk add --no-cache \
  ca-certificates \
  chromium@edge=115.0.5790.110-r0 \
  dumb-init \
  chromium \
  harfbuzz \
  fontconfig \
  font-ipa \
  font-noto \
  font-noto-emoji \
  freetype \
  freetype-dev \
  gtk+3.0 \
  msttcorefonts-installer \
  nss \
  ttf-freefont \
  unzip
# If you don't need unzip, remove it, but it's probably there by default anyway

# microsoft-true-font
RUN update-ms-fonts

# Google fonts
RUN mkdir -p /tmp/google-fonts \
  && wget https://github.com/google/fonts/archive/master.tar.gz -O /tmp/google-fonts/fonts.tar.gz \
  && cd /tmp/google-fonts \
  && tar -xf fonts.tar.gz \
  && mkdir -p $FONT_DIR/truetype/google-fonts \
  && find $PWD/fonts-main/ -name "*.ttf" -exec install -m644 {} $FONT_DIR/truetype/google-fonts/ \; || return 1

# Reload fonts
RUN fc-cache -f 

# Copy files to the container except those specified in .dockerignore
WORKDIR /app
RUN chown node:node /app
COPY --chown=node:node . .

# .dockerignore seems to be ignored
RUN rm -rf node_modules

# Populate node_modules
RUN npm ci --omit=dev

# Clean up
RUN rm -rf /tmp/*

USER node
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

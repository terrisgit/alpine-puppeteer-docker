# 👀 Overview
#
# This Dockerfile installs Puppeteer under Alpine with a large number of fonts for pixel-perfect
# PDF generation. However, the fonts installed herein may be redundant and some might even be
# missing. This Dockerfile is used in production but it might not be perfect for your needs.
#
# 🐋 Dockerfiles
# This Dockerfile: https://github.com/terrisgit/alpine-puppeteer-docker
# https://github.com/Yelp/dumb-init
# https://stackoverflow.com/questions/66512149/headless-chromium-in-ubuntu-docker-container
# https://github.com/MontFerret/chromium 
# https://github.com/tkp1n/chromium-ci
# https://github.com/Zenika/alpine-chrome
#
# 🦄 Puppeteer
# https://apitemplate.io/blog/tips-for-generating-pdfs-with-puppeteer
# https://github.com/puppeteer/puppeteer/blob/main/docs/troubleshooting.md
# https://www.koyeb.com/tutorials/deploy-a-web-scraper-using-puppeteer-node-and-docker
#
# 🎨 Chromium Versions
# https://pptr.dev/chromium-support
# https://pkgs.alpinelinux.org/packages?name=chromium&branch=edge&repo=&arch=x86_64
#
# 🅰️ Fonts
# https://unix.stackexchange.com/questions/438257/how-to-install-microsoft-true-type-font-on-alpine-linux
# https://github.com/alpaca-tc/puppeteer-pdf-generator/blob/master/Dockerfile
#
# 🚥 Recommended Chromium Arguments
# https://peter.sh/experiments/chromium-command-line-switches
# https://simpleit.rocks/linux/ubuntu/fixing-common-google-chrome-gpu-process-error-message-in-linux
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
# --disable-popup-blocking
# --disable-print-preview
# --disable-prompt-on-repost
# --disable-renderer-backgrounding
# --disable-setuid-sandbox
# --disable-site-isolation-trials
# --disable-software-rasterizer
# --disable-speech-api
# --disable-sync
# --disable-translate
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
#
# 🚥 More Chromium Arguments to Consider
# --single-process on AWS Fargate or Lambda - See https://github.com/puppeteer/puppeteer/issues/6776
# --disable-3d-apis
# --disable-accelerated-2d-canvas 
# --disable-accelerated-jpeg-decoding 
# --disable-accelerated-mjpeg-decode 
# --disable-accelerated-video-decode
# --disable-app-list-dismiss-on-blur 
# --disable-canvas-aa 
# --disable-component-extensions-with-background-pages
# --disable-composited-antialiasing
# --disable-features=TranslateUI 
# --disable-gl-extensions
# --disable-histogram-customizer 
# --disable-in-process-stack-traces
# --disable-offer-store-unmasked-wallet-cards
# --disable-threaded-animation 
# --disable-threaded-scrolling
# --disable-webgl
# --enable-automation
# --enable-blink-features=IdleDetection 
# --enable-features=NetworkService,NetworkServiceInProcess 
# --ignore-certificate-errors 
# --ignore-certificate-errors-spki-list
# --log-level=3 
# --no-experiments 
# --remote-debugging-port=0 
# --renderer-process-limit=2 (to reduce memory usage which might reduce page crashes)

ARG REPO=node:20-alpine
FROM $REPO

ARG CHROMIUM=chromium@edge=116.0.5845.110-r0

################################################################
# Environment variables
#
ENV FONT_DIR=/usr/share/fonts
#
# Tell Puppeteer to not install Chrome. It's installed via APK.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
#
# Where is Chromium?
ENV CHROME_PATH=/usr/lib/chromium/
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
#
# Puppeteer debugging
# ENV DEBUG=puppeteer:*
ENV DEBUG_COLORS=true
#
################################################################

RUN apk update
RUN apk upgrade --no-cache

RUN echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
  && echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories 

RUN apk add --no-cache \
  ca-certificates \
  $CHROMIUM \
  dumb-init \
  chromium \
  harfbuzz \
  fontconfig \
  font-ipa \
  font-noto \
  font-noto-cjk \
  font-noto-emoji \
  freetype \
  freetype-dev \
  gtk+3.0 \
  msttcorefonts-installer \
  nss \
  ttf-dejavu \
  ttf-droid \
  ttf-freefont \
  ttf-liberation

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

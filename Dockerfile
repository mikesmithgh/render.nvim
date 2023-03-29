ARG PLAYWRIGHT_VERSION=1.32.0

FROM ubuntu:focal AS builder
ARG AHA_VERSION=0.5.1
ENV AHA_VERSION=$AHA_VERSION
RUN apt update && apt install curl build-essential -y
WORKDIR /aha
RUN curl -L "https://github.com/theZiz/aha/archive/refs/tags/$AHA_VERSION.tar.gz" -o aha.tar.gz
RUN tar --strip-components=1 -xvf aha.tar.gz
RUN make

FROM mcr.microsoft.com/playwright:v$PLAYWRIGHT_VERSION-focal
ENV NODE_PATH=/opt/lib/node_modules
RUN npm install -g @playwright/test && \
    npx --yes playwright install --with-deps
COPY --from=builder /aha/aha /usr/local/bin/
LABEL org.opencontainers.image.source https://github.com/mikesmithgh/render.nvim


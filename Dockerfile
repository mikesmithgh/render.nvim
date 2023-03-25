# TODO:
# - add args for env vars
# - create script to build
# - add CI/CD and publish to github container registry
FROM ubuntu:focal AS builder
RUN apt update && apt install curl build-essential -y
WORKDIR /aha
RUN curl -L  https://github.com/theZiz/aha/archive/refs/tags/0.5.1.tar.gz -o aha.tar.gz
RUN tar --strip-components=1 -xvf aha.tar.gz
RUN make

FROM mcr.microsoft.com/playwright:v1.32.0-focal
ENV NODE_PATH=/opt/lib/node_modules
RUN apt update && apt install aha
RUN npm install -g @playwright/test
RUN npx --yes playwright install --with-deps
COPY --from=builder /aha/aha /usr/local/bin/
LABEL org.opencontainers.image.source https://github.com/mikesmithgh/render.nvim

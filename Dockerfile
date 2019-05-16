FROM ubuntu:18.04
MAINTAINER Fabian Beuke <beuke@traum-ferienwohnungen.de>

RUN apt-get update &&                          \
    apt-get install -y --no-install-recommends \
    fontconfig                                 \
    libcurl3                                   \
    libcurl3-gnutls                            \
    libfontconfig1                             \
    libfreetype6                               \
    libjpeg-turbo8                             \
    libx11-6                                   \
    libxext6                                   \
    libxrender1                                \
    nodejs                                     \
    npm                                        \
    software-properties-common                 \
    wget                                       \
    xfonts-75dpi                               \
    xfonts-base

ENV WK_URL=https://downloads.wkhtmltopdf.org/0.12/0.12.2.1
ENV WK_PKG=wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
ENV LPNG_URL=http://se.archive.ubuntu.com/ubuntu/pool/main/libp/libpng
ENV LPNG_PKG=libpng12-0_1.2.54-1ubuntu1_amd64.deb

RUN wget -q $WK_URL/$WK_PKG     && \
    wget -q $LPNG_URL/$LPNG_PKG && \
    dpkg -i $LPNG_PKG           && \
    dpkg -i $WK_PKG             && \
    rm /usr/local/bin/wkhtmltoimage

RUN npm install -g    \
    yarn              \
    coffee-script     \
    forever bootprint \
    bootprint-openapi

# generate documentation from swagger
COPY swagger.yaml /

RUN bootprint openapi swagger.yaml documentation && \
    npm uninstall -g                                \
    bootprint                                       \
    bootprint-openapi

# install npm dependencies
COPY package.json /

RUN yarn install

COPY app.coffee /

EXPOSE 5555

RUN node   --version && \
    npm    --version && \
    coffee --version

CMD ["npm", "start"]

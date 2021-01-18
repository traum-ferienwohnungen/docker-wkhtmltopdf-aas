FROM ubuntu:20.04 
MAINTAINER Fabian Beuke <beuke@traum-ferienwohnungen.de> EDITED By Leknoppix

RUN apt-get update &&                          \
    apt-get install -y --no-install-recommends \
    fontconfig                                 \
    curl				       \
    libcurl4                                   \
    libcurl3-gnutls                            \
    libfontconfig1                             \
    libfreetype6                               \
    libjpeg-turbo8                             \
    libx11-6                                   \
    libxext6                                   \
    libxrender1                                \
    software-properties-common                 \
    wget                                       \
    xfonts-75dpi                               \
    xfonts-base  			       \
    python

RUN apt-get install -y add-apt-key

RUN cd ~

RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh

RUN bash nodesource_setup.sh

RUN apt install nodejs

ENV WK_URL=https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1
ENV WK_PKG=wkhtmltox_0.12.6-1.focal_amd64.deb
ENV LPNG_URL=http://se.archive.ubuntu.com/ubuntu/pool/main/libp/libpng
ENV LPNG_PKG=libpng12-0_1.2.54-1ubuntu1_amd64.deb

RUN apt-get install -y libpng-dev

RUN wget -q $WK_URL/$WK_PKG     && \
    dpkg -i $WK_PKG             && \
    rm /usr/local/bin/wkhtmltoimage

RUN npm install -g          \
    coffeescript           \
    forever bootprint       \
    bootprint-openapi

# generate documentation from swagger
COPY swagger.yaml /

RUN bootprint openapi swagger.yaml documentation && \
    npm uninstall -g                                \
    bootprint                                       \
    bootprint-openapi

# install npm dependencies
COPY package.json /

RUN npm update

COPY app.coffee /

EXPOSE 5555

RUN node   --version && \
    npm    --version && \
    coffee --version

CMD ["npm", "start"]

FROM ubuntu:20.04 
MAINTAINER Fabian Beuke <beuke@traum-ferienwohnungen.de> EDITED By Leknoppix

RUN apt-get update &&                          \
    apt-get install -y --no-install-recommends \
    add-apt-key                                \
    fontconfig                                 \
    curl				                       \
    libcurl4                                   \
    libcurl3-gnutls                            \
    libfontconfig1                             \
    libfreetype6                               \
    libjpeg-turbo8                             \
    libpng-dev                                 \
    libx11-6                                   \
    libxext6                                   \
    libxrender1                                \
    software-properties-common                 \
    wget                                       \
    xfonts-75dpi                               \
    xfonts-base  			                   \
    python

ENV WK_URL=https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/ \
    WK_PKG=wkhtmltox_0.12.5-1.focal_amd64.deb

COPY swagger.yaml package.json app.coffee /

RUN curl -sL https://deb.nodesource.com/setup_14.x                     \
    -o /tmp/nodesource_setup.sh && bash /tmp/nodesource_setup.sh    && \
    rm /tmp/nodesource_setup.sh

RUN apt-get install -y --no-install-recommends nodejs

RUN wget -q $WK_URL/$WK_PKG && dpkg -i $WK_PKG && rm $WK_PKG        && \
    rm /usr/local/bin/wkhtmltoimage

RUN npm install -g coffeescript forever bootprint bootprint-openapi && \
    bootprint openapi swagger.yaml documentation                    && \
    npm uninstall -g bootprint bootprint-openapi

RUN npm update       && \
    node   --version && \
    npm    --version && \
    coffee --version

EXPOSE 5555

CMD ["npm", "start"]

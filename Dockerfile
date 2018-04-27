FROM ubuntu:16.04
MAINTAINER Fabian Beuke <beuke@traum-ferienwohnungen.de>

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:no1wantdthisname/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends npm wget xz-utils build-essential \
    fontconfig fontconfig-infinality freetype2-demos libx11-6 libxext6 libxrender1 apt-utils \
    libcurl4-gnutls-dev librtmp-dev curl python-software-properties \
    xfonts-base xfonts-75dpi libjpeg-turbo8 && \
    wget -q https://downloads.wkhtmltopdf.org/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    rm /usr/local/bin/wkhtmltoimage && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs

RUN npm install -g yarn coffeescript forever bootprint bootprint-openapi

# generate documentation from swagger
COPY swagger.yaml /
RUN bootprint openapi swagger.yaml documentation && \
    npm uninstall -g bootprint bootprint-openapi

# install dependencies
COPY package.json /
RUN yarn install

COPY app.coffee /

EXPOSE 5555

RUN node --version && \
    npm --version && \
    coffee --version

CMD ["npm", "start"]

FROM ubuntu:16.04
MAINTAINER Fabian Beuke <beuke@traum-ferienwohnungen.de>

RUN apt-get update && \
    apt-get install -y --no-install-recommends npm wget fontconfig \
    libfontconfig1 libfreetype6 libjpeg-turbo8 libx11-6 libxext6 \
    libxrender1 xfonts-base xfonts-75dpi curl python-software-properties && \
    wget -q http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    dpkg -i wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    rm /usr/local/bin/wkhtmltoimage && \
    curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
    apt-get install -y nodejs

RUN npm install -g yarn coffee-script forever bootprint bootprint-openapi

COPY app.coffee /
COPY package.json /
COPY swagger.yaml /

RUN yarn install

# Generate Documentation from swagger
RUN bootprint openapi swagger.yaml documentation && \
    npm uninstall -g bootprint bootprint-openapi

EXPOSE 5555

RUN node --version && \
    npm --version && \
    coffee --version

CMD ["npm", "start"]

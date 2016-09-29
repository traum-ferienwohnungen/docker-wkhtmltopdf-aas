FROM traumfewo/docker-wkhtmltopdf:latest
MAINTAINER Fabian Beuke <beuke@traum-ferienwohnungen.de>

RUN apt-get update && \
    apt-get install -y wget && \
    wget -qO- https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g coffee-script forever && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

COPY app.coffee /
COPY package.json /
COPY swagger.yaml /

WORKDIR /

RUN npm install

# Generate Documentation from swagger
RUN npm install -g bootprint bootprint-openapi && \
    bootprint openapi swagger.yaml documentation && \
    npm uninstall -g bootprint bootprint-openapi

EXPOSE 5555

RUN node --version && \
    npm --version && \
    coffee --version

ENTRYPOINT ["npm", "start"]

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

COPY swagger.yaml package.json app.coffee /

RUN curl -sL https://deb.nodesource.com/setup_14.x                     \
    -o /tmp/nodesource_setup.sh && bash /tmp/nodesource_setup.sh    && \
    rm /tmp/nodesource_setup.sh

RUN apt-get install -y --no-install-recommends nodejs

# Déterminer l'architecture
RUN ARCHITECTURE="$(dpkg --print-architecture)"

# Utiliser une condition pour définir l'URL en fonction de l'architecture
RUN if [ "$ARCHITECTURE" = "arm64" ]; then \
        URL="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-rc/wkhtmltox_0.12.6-0.20200605.30.rc.faa06fa.focal_arm64.deb"; \
    elif [ "$ARCHITECTURE" = "amd64" ]; then \
        URL="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-rc/wkhtmltox_0.12.6-0.20200605.30.rc.faa06fa.focal_amd64.deb"; \
    else \
        echo "Architecture non supportée"; \
        exit 1; \
    fi

RUN wget -q $URL -O wkhtmltopdf.deb

RUN dpkg -i wkhtmltopdf.deb

RUN rm wkhtmltopdf.deb

RUN rm /usr/local/bin/wkhtmltoimage

RUN npm install -g coffeescript forever bootprint bootprint-openapi && \
    bootprint openapi swagger.yaml documentation                    && \
    npm uninstall -g bootprint bootprint-openapi

RUN npm update       && \
    node   --version && \
    npm    --version && \
    coffee --version

EXPOSE 5555

CMD ["npm", "start"]

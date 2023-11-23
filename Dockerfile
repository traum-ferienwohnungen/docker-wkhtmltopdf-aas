FROM ubuntu:22.04

RUN apt-get update &&                          \
    apt install -y --no-install-recommends \
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
    xfonts-base

COPY swagger.yaml package.json app.coffee /

RUN mkdir -p /etc/apt/keyrings

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt update && apt install -y --no-install-recommends nodejs && apt install wkhtmltopdf

RUN npm install -g coffeescript forever bootprint bootprint-openapi && \
    bootprint openapi swagger.yaml documentation                    && \
    npm uninstall -g bootprint bootprint-openapi

RUN npm update       && \
    node   --version && \
    npm    --version && \
    coffee --version

EXPOSE 5555

CMD ["npm", "start"]

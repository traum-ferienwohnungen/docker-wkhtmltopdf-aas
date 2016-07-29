FROM traumfewo/docker-wkhtmltopdf:v0.12.2.1
MAINTAINER Fabian Beuke <beuke@traum-ferienwohnungen.de>

RUN apt-get update && \
    apt-get install -y --no-install-recommends python-pip && \
    pip install werkzeug executor gunicorn prometheus_client && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

ADD src/* /
EXPOSE 5555 9191

ENTRYPOINT ["usr/local/bin/gunicorn"]

CMD ["-b", "0.0.0.0:5555", "-b", "0.0.0.0:9191", "--log-file", "-", "app:application"]

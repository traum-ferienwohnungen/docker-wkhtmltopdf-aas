FROM traumfewo/docker-wkhtmltopdf:v0.12.2.1
MAINTAINER Fabian Beuke <beuke@traum-ferienwohnungen.de>

RUN apt-get update && \
    apt-get install -y --no-install-recommends python-pip && \
    pip install werkzeug executor gunicorn prometheus_client && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

ADD app.py /
EXPOSE 5555

ENTRYPOINT ["usr/local/bin/gunicorn"]

CMD ["-b", "0.0.0.0:5555", "--log-file", "-", "app:application"]

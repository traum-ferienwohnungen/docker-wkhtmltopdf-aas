FROM openlabs/docker-wkhtmltopdf:latest
MAINTAINER Fabian Beuke <beuke@traum-ferienwohnungen.de>

# Install dependencies for running web service
RUN apt-get update && apt-get install -y python-pip
RUN pip install werkzeug executor gunicorn

ADD app.py /app.py
EXPOSE 5555

ENTRYPOINT ["usr/local/bin/gunicorn"]

# Show the extended help
CMD ["-b", "0.0.0.0:5555", "--log-file", "-", "app:application"]

# docker-wkhtmltopdf-aas
[![License (3-Clause BSD)](https://img.shields.io/badge/license-BSD%203--Clause-brightgreen.svg)](http://opensource.org/licenses/BSD-3-Clause)
[![Build Status](https://travis-ci.org/traum-ferienwohnungen/docker-wkhtmltopdf-aas.svg?branch=master)](https://travis-ci.org/traum-ferienwohnungen/docker-wkhtmltopdf-aas)
[![Code Climate](https://codeclimate.com/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas/badges/gpa.svg)](https://codeclimate.com/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas)
[![Issue Count](https://codeclimate.com/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas/badges/issue_count.svg)](https://codeclimate.com/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas)
[![Test Coverage](https://codeclimate.com/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas/badges/coverage.svg)](https://codeclimate.com/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas/coverage)
[![dependencies Status](https://david-dm.org/traum-ferienwohnungen/docker-wkhtmltopdf-aas/status.svg)](https://david-dm.org/traum-ferienwohnungen/docker-wkhtmltopdf-aas)
[![bitHound Overall Score](https://www.bithound.io/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas/badges/score.svg)](https://www.bithound.io/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas)
[![](https://images.microbadger.com/badges/image/traumfewo/docker-wkhtmltopdf-aas.svg)](http://microbadger.com/images/traumfewo/docker-wkhtmltopdf-aas)
[![Known Vulnerabilities](https://snyk.io/test/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas/badge.svg)](https://snyk.io/test/github/traum-ferienwohnungen/docker-wkhtmltopdf-aas)

wkhtmltopdf in a docker container as a rest api web service.

## Live demo

[https://docker-wkhtmltopdf-aas.herokuapp.com](https://docker-wkhtmltopdf-aas.herokuapp.com)<br>
User: gooduser<br>
Pass: secretpassword


## Running the service

```bash
docker build -t pdf-service .
docker run -t -e USER='gooduser' -e PASS='secretpassword' -p 127.0.0.1:80:5555 pdf-service
```

## Using the webservice via JSON API
#### Python example

```python
import json
import requests
url = 'https://"+user+":"+pass+"@<docker_host>:<port>/'
data = {
    'contents': open('/file/to/convert.html').read().encode('base64'),
    'options': {
        'margin-right': '20',
        'margin-bottom': '20',
        'page-width': '105mm',
        'page-height': '40mm'
    }
}
headers = { 'Content-Type': 'application/json', }
response = requests.post(url, data=json.dumps(data), headers=headers)
with open('/path/to/local/file.pdf', 'wb') as f:
    f.write(response.content)
```

#### Shell example
```bash
content=$(echo "<html>Your HTML content</html>" | base64)
footer=$(echo "<html>Your HTML footer</html>" | base64)
curl -vvv -H "Content-Type: application/json" -X POST -d \
    '{"contents": "'"$content"'",
      "options": {
        "margin-top": "20",
        "margin-left": "20",
        "margin-right": "20",
        "margin-bottom": "30"
      },
      "footer": "'"$footer"'"}' \
https://"+user+":"+pass+"@<docker_host>:<port> -o OUTPUT_NAME.pdf
```
#### PHP example
```php
$url = 'https://"+user+":"+pass+"@<docker_host>:<port>/';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-type: application/json'));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$body = json_encode([
    'contents' => base64_encode($html),
]);
# print response
curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
echo curl_exec($ch);

```

## Additional Options

#### Payload Size

It might be useful to increase the payload size to allow the generation of larger PDF files in case of errors such as `Error: request entity too large`. You can configure the payload size limit for the body parser by adding the additional `PAYLOAD_LIMIT` environment variable to the `docker run -t ` start command. For instance, set the payload limit to 80 megabyte by adding ` -e PAYLOAD_LIMIT='80mb'`. Please consider that a high payload limit might result in high server resource usage and longer response times.
## Features

The containing features are easy to disable in case you don't need them. <br> For example disable prometheus metrics:
```coffeescript
app.use status()
# app.use prometheusMetrics()
app.use log('combined')
app.use '/', express.static(__dirname + '/documentation')
```

**Auto generated self-hosting documentation (/)**

![alt text](https://i.imgur.com/ikv7Zg7.png)


**Simple Service Status Overview (/status)**

![alt text]( https://i.imgur.com/ELq65Ie.png)


**Standard Apache combine format HTTP logging (stdout)**
```
::ffff:172.17.0.1 - - [11/Sep/2016:14:04:15 +0000] "GET / HTTP/1.1" 200 13500 "-" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.101 Safari/537.36"
::ffff:172.17.0.1 - - [11/Sep/2016:14:04:15 +0000] "GET /main.css HTTP/1.1" 200 133137 "http://localhost/" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.101 Safari/537.36"
::ffff:172.17.0.1 - - [11/Sep/2016:14:04:16 +0000] "GET /favicon.ico HTTP/1.1" 404 24 "http://localhost/" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.101 Safari/537.36"
```

**Prometheus Metrics for service monitoring (/metrics)**
```
# HELP up 1 = up, 0 = not up
# TYPE up gauge
up 1
# HELP nodejs_memory_heap_total_bytes value of process.memoryUsage().heapTotal
# TYPE nodejs_memory_heap_total_bytes gauge
nodejs_memory_heap_total_bytes 29421568
# HELP nodejs_memory_heap_used_bytes value of process.memoryUsage().heapUsed
# TYPE nodejs_memory_heap_used_bytes gauge
nodejs_memory_heap_used_bytes 22794784
# HELP http_request_seconds number of http responses labeled with status code
# TYPE http_request_seconds histogram
```

## Security

The API is protected by basic access authentication. Keep in mind that the basic access authentication mechanism provides no confidentiality protection for the transmitted credentials. The credentials are only base64 encoded, but not encrypted or hashed in any way. The usage of HTTPS is therefore mandatory.

## Tests

In order to run the test suite you need to first setup the docker container, install the deps and run `yarn test`:

```bash
docker build -t pdf-service .
docker run -t -e USER='gooduser' -e PASS='secretpassword' -p 127.0.0.1:80:5555 pdf-service
yarn install
yarn test
```

## Philosophy
This Service follows the following design principles
- horizontal scalability -> stateless
- don't reeinvent the wheel -> libraries
- high quality -> 100% code coverage
- keep it simple stupid (kiss) -> few files, few sloc, no stuff
- high performance -> non blocking functional asynchronous code

## Contributing

Issues, pull requests and questions are welcome.<br>
The development of the container takes place on
[Github](https://github.com/traum-ferienwohnungen/docker-wkhtmltopdf-aas/issues).<br>If you have a question or a bug report to file, you can report as a Github issue.


### Pull Requests

- fork the repository
- make changes
- if required, write tests covering the new functionality
- ensure all tests pass and 100% code coverage is achieved (run `yarn test`)
- raise pull request

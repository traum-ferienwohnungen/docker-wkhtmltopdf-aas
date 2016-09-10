# docker-wkhtmltopdf-aas
[![License (3-Clause BSD)](https://img.shields.io/badge/license-BSD%203--Clause-brightgreen.svg)](http://opensource.org/licenses/BSD-3-Clause)
[![Build Status](https://travis-ci.org/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas.svg?branch=master)](https://travis-ci.org/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas)
[![Code Climate](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas/badges/gpa.svg)](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas)
[![Issue Count](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas/badges/issue_count.svg)](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas)
[![Test Coverage](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas/badges/coverage.svg)](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas/coverage)
[![dependencies Status](https://david-dm.org/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas/status.svg)](https://david-dm.org/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas)
[![bitHound Overall Score](https://www.bithound.io/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas/badges/score.svg)](https://www.bithound.io/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas)
[![](https://images.microbadger.com/badges/image/traumfewo/docker-wkhtmltopdf-aas.svg)](http://microbadger.com/images/traumfewo/docker-wkhtmltopdf-aas)

wkhtmltopdf in a docker container as a web service.

This image is based on the
[wkhtmltopdf container](https://hub.docker.com/r/traumfewo/docker-wkhtmltopdf).

## Running the service

Run the container with docker run and binding the ports to the host.
The web service is exposed on port 80 in the container.

```sh
docker run -d -e API_TOKEN='your-secret-api-token' -p 127.0.0.1:80:5555
```

Take a note of the public port number where docker binds to.

## Using the webservice via JSON API
#### Python example

```python
import json
import requests

url = 'http://<docker_host>:<port>/'
data = {
    'contents': open('/file/to/convert.html').read().encode('base64'),
    'token': 'your-secret-api-token',
    'options': {
        'margin-top': '6',
        'margin-left': '6',
        'margin-right': '6',
        'margin-bottom': '6',
        'page-width': '105mm',
        'page-height': '40mm'
    }
}
headers = {
    'Content-Type': 'application/json',
}
response = requests.post(url, data=json.dumps(data), headers=headers)

# Save the response contents to a file
with open('/path/to/local/file.pdf', 'wb') as f:
    f.write(response.content)
```

#### Shell example
```bash
content=$(echo "<html>Your HTML content</html>" | base64)
footer=$(echo "<html>Your HTML footer</html>" | base64)

curl -vvv -H "Content-Type: application/json" -X POST -d \
    '{"contents": "'"$content"'",
      "token": "your-secret-api-token",
      "options": {
        "margin-top": "20",
        "margin-left": "20",
        "margin-right": "20",
        "margin-bottom": "30"
      },
      "footer": "'"$footer"'"}' \
    http://<docker_host>:<port> -o OUTPUT_NAME.pdf
```
#### PHP example
```php
$url = 'http://<docker_host>:<port>/';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-type: application/json'));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$body = json_encode([
    'contents' => base64_encode($html),
    'token' => 'your-secret-api-token',
]);
# print response
curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
echo curl_exec($ch);

```

## Security

This service exposes two ports 5555 and 9191. The Port 9191 should be only available internally (e.g. 127.0.0.1) since there is no api token / security mechanism for prometheus metrics yet. The API is secured by an api token and can therefore be public (0.0.0.0).

## Bugs and questions

The development of the container takes place on
[Github](https://github.com/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas). If you
have a question or a bug report to file, you can report as a github issue.

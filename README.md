# docker-wkhtmltopdf-aas 
[![Build Status](https://travis-ci.org/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas.svg?branch=master)](https://travis-ci.org/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas)
[![Code Climate](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas/badges/gpa.svg)](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas)
[![Issue Count](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas/badges/issue_count.svg)](https://codeclimate.com/github/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas)

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

When passing our settings we omit the double dash "--" at the start of the option.
For documentation on what options are available, visit http://wkhtmltopdf.org/usage/wkhtmltopdf.txt

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

## Bugs and questions

The development of the container takes place on 
[Github](https://github.com/Traum-Ferienwohnungen/docker-wkhtmltopdf-aas). If you
have a question or a bug report to file, you can report as a github issue.

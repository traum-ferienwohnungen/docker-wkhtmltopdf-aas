import json
import requests

url = 'http://127.0.0.1:80';

data = {
        'contents': '<html>hello world</html>'.encode('base64'),
        'token': 'travisci-test123456789',
       }

headers = {
            'Content-Type': 'application/json',
          }

response = requests.post(url, data=json.dumps(data), headers=headers)

print response.content

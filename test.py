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

# test with valid token 
response = requests.post(url, data=json.dumps(data), headers=headers)
ctype = response.headers['content-type']
status = response.status_code

if ctype != "application/pdf":
    print("content type test failed: content type is " + ctype + ", pdf expected")
    exit(1)

if status != 200:
    print("status code test failed: got " + str(status) + ", 200 expected")
    exit(1)

# test with invalid token 
data = {
                'contents': '<html>hello world</html>'.encode('base64'),
                'token': 'this-is-a-invalid-token',
       }

response = requests.post(url, data=json.dumps(data), headers=headers)
ctype = response.headers['content-type']
status = response.status_code

if status != 401:
     print("status code test failed: got " + str(status) + ", 401 expected")
     exit(1)

if ctype == "application/pdf":
    print("content type test failed: content type is " + ctype + ", no pdf expected")
    exit(1)

print("all tests passed successfully")

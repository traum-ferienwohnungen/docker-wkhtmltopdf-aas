#!/usr/bin/env python
import argparse
import json
import requests
import logging

import sys

logging.basicConfig(level=logging.DEBUG, stream=sys.stderr)


def run_tests(url, token):
    data = {
        'contents': '<html>hello world</html>'.encode('base64'),
        'token': token,
    }

    headers = {
        'Content-Type': 'application/json',
    }

    # test with valid token
    response = requests.post(url, data=json.dumps(data), headers=headers)
    content_type = response.headers['content-type']
    status = response.status_code

    errors = []
    if status != 200:
        errors.append(
            "status code test failed: got " + str(status) + ", 200 expected"
        )

    if content_type != "application/pdf":
        errors.append(
            'content type test failed: content type is {0}, application/pdf expected'.format(
                content_type
            )
        )

    # test with invalid token
    data = {
        'contents': '<html>hello world</html>'.encode('base64'),
        'token': 'this-is-a-invalid-token',
    }

    response = requests.post(url, data=json.dumps(data), headers=headers)
    content_type = response.headers['content-type']
    status = response.status_code

    if status != 401:
        errors.append(
            "status code test failed: got " + str(status) + ", 401 expected"
        )

    if content_type == "application/pdf":
        errors.append(
            "content type test failed: content type is " + content_type + ", no pdf expected"
        )

    if errors:
        print('\n'.join(errors))
        exit(1)
    else:
        print("all tests passed successfully")


def main():
    argparse.ArgumentParser()
    parser = argparse.ArgumentParser(
        description='Test docker-wkhtmltopdf-aas')
    parser.add_argument('--url', default='http://127.0.0.1:80')
    parser.add_argument('--token', default='travisci-test123456789')

    args = parser.parse_args()
    run_tests(args.url, args.token)

if __name__ == '__main__':
    main()

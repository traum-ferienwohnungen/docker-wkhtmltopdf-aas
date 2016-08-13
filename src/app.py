#! /usr/bin/env python
"""
    WSGI APP to convert wkhtmltopdf as a webservice
    :copyright: (c) 2013 by Openlabs Technologies & Consulting (P) Limited
    :license: BSD, see LICENSE for more details.
"""
import json
import tempfile
import os
import httplib as status

from time import time
from werkzeug.wsgi import wrap_file
from werkzeug.wrappers import Request, Response
from werkzeug.serving import run_simple
from executor import execute
from pipes import quote
from operator import add
from prometheus import prometheus_metrics

@Request.application
@prometheus_metrics(9191, '/metrics', ('/', '/healthz'))
def application(request):

    if request.method == 'GET':
        return Response(status=status.OK)

    if request.method != 'POST' or not request.content_type.endswith('json'):
        return Response(status=status.METHOD_NOT_ALLOWED)

    # If a JSON payload is there, all data is in the payload
    payload = json.loads(request.data)
    footer_file = source_file = tempfile.NamedTemporaryFile(suffix='.html')
    token = payload.get('token', {})

    # Auth Token Check
    if os.environ.get('API_TOKEN') != token:
        return Response(status=status.UNAUTHORIZED)

    if payload.has_key('footer'):
        footer_file.write(payload['footer'].decode('base64'))

    source_file.write(payload['contents'].decode('base64'))
    options = payload.get('options', {})
    source_file.flush() and footer_file.flush()
    args = ['wkhtmltopdf']

    # Add Global Options
    if options:
        args += reduce(add, map(lambda (option,value):
            ['--' + quote(option), quote(value)], options.items()))

    # Add footer and source
    file_name = source_file.name + ".pdf"
    args += ["--footer-html", footer_file.name]
    args += [source_file.name, file_name]

    # Execute the command using executor
    execute(' '.join(args))

    return Response(
        wrap_file(request.environ, open(file_name)),
        mimetype='application/pdf',
    )

if __name__ == '__main__':
    run_simple('127.0.0.1', 5000, application)


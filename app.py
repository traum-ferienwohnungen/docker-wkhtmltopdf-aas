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
from executor import execute
from pipes import quote

@Request.application
def application(request):

    if request.method == 'GET':
        return Response(status=status.OK)

    if request.method != 'POST':
        return Response(status=status.METHOD_NOT_ALLOWED)

    request_is_json = request.content_type.endswith('json')
    footer_file = tempfile.NamedTemporaryFile(suffix='.html')

    with tempfile.NamedTemporaryFile(suffix='.html') as source_file:

        token = None
        options = None
        if request_is_json:
            # If a JSON payload is there, all data is in the payload
            payload = json.loads(request.data)
            source_file.write(payload['contents'].decode('base64'))
            if payload.has_key('footer'):
                footer_file.write(payload['footer'].decode('base64'))
            options = payload.get('options', {})
            token = payload.get('token', {})

        elif request.files:
            # First check if any files were uploaded
            source_file.write(request.files['file'].read())
            # Load any options that may have been provided in options
            options = json.loads(request.form.get('options', '{}'))
            token = json.loads(request.form.get('token', '{}'))

        source_file.flush()
        footer_file.flush()

        # Auth Token Check
        if os.environ.get('API_TOKEN') != token:
            return Response('Unauthorized', status=status.UNAUTHORIZED)

        # Evaluate argument to run with subprocess
        args = ['wkhtmltopdf']

        # Add Global Options
        if options:
            for option, value in options.items():
                args.append('--' + quote(option))
                if value:
                    args.append(quote(value))

        # Add footer file name and output file name
        file_name = footer_file.name 
        args += ["--footer-html", file_name ]

        # Add source file name and output file name
        file_name = source_file.name
        args += [file_name, file_name + ".pdf"]

        # Execute the command using executor
        execute(' '.join(args))

        return Response(
            wrap_file(request.environ, open(file_name + '.pdf')),
            mimetype='application/pdf',
        )


if __name__ == '__main__':
    from werkzeug.serving import run_simple
    run_simple(
        '127.0.0.1', 5000, application
    )

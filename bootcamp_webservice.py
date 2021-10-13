#!/usrbin/env python3
import logging

from flask import Flask, request, json, send_file, render_template
from werkzeug.exceptions import HTTPException
from bootcamp import Generator
import json
import sys
import os
import tempfile
import traceback

app = Flask(__name__)

BOOTCAMP_CONFIG_FILENAME_CONFIG = 'BOOTCAMP_CONFIG_FILENAME'
CONFIG_FILE = "config-file"
CLIENT_FILE = "clients.zip"

def format_stacktrace():
    parts = ["Traceback (most recent call last):\n"]
    parts.extend(traceback.format_stack(limit=25)[:-2])
    parts.extend(traceback.format_exception(*sys.exc_info())[1:])
    return "".join(parts)

@app.errorhandler(Exception)
def handle_exception(error):
    # pass through HTTP errors
    if isinstance(error, HTTPException):
        return error

    # now you're handling non-HTTP exceptions only
    logger = logging.getLogger('bootcamp')
    logger.exception(error)
    return render_template("500_generic.html", exception=format_stacktrace()), 500

@app.route('/generate', methods=['POST'])
def invoke_generator():
    logger = logging.getLogger('bootcamp')
    data_bytes = request.data
    hosts = json.loads(data_bytes)

    tmpdir = tempfile.TemporaryDirectory(prefix='bootcamp_')

    logger.info(f"Created {tmpdir}")

    config_file = find_config_file()

    generator = Generator(tmpdir.name, config_file, hosts, "web-user")
    filename = os.path.join(tmpdir.name, generator.zip_file_name)

    result = send_file(filename, attachment_filename=filename, mimetype='application/zip')

    return result


@app.route('/verify', methods=['POST'])
def verify_input():
    logger = logging.getLogger('bootcamp')
    data_bytes = request.data
    logger.info(data_bytes)

    return data_bytes

@app.route('/client/defaults', methods=['GET'])
def get_default_clients():
    client_filename = CLIENT_FILE
    result = send_file(client_filename, attachment_filename=client_filename, mimetype='application/zip')

    return result

def find_config_file():
    if CONFIG_FILE in app.config:
        config_file = app.config[CONFIG_FILE]
    else:
        if BOOTCAMP_CONFIG_FILENAME_CONFIG in os.environ:
            config_file = os.environ[BOOTCAMP_CONFIG_FILENAME_CONFIG]

    if os.path.exists(config_file):
        return os.path.abspath(config_file)
    else:
        print(f"Usage: sys.argv[0] <config-file>", file=sys.stderr)
        print(f"Or specify {BOOTCAMP_CONFIG_FILENAME_CONFIG} in the environment", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        app.config[CONFIG_FILE] = sys.argv[1]

    app.run(debug=True)

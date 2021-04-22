#!/usrbin/env python3

from flask import Flask, request, send_file
from bootcamp import Generator
import json
import sys
import os

app = Flask(__name__)


@app.route('/generate', methods=['POST'])
def invoke_generator():
    data_bytes = request.data
    hosts = json.loads(data_bytes)

    generator = Generator(app.config['config-file'], hosts, "web-user")
    filename = generator.zip_file_name

    result = send_file(filename, attachment_filename=filename, mimetype='application/zip')

    os.unlink(filename)

    return result


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"Usage: sys.argv[0] <config-file>")
        sys.exit(1)

    app.config['config-file'] = sys.argv[1]
    app.run(debug=True)

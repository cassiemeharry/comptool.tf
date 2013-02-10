from flask import request

from comptool import app

@app.route('/')
def host_check():
    return 'Requested from %s' % request.environ['HTTP_HOST']

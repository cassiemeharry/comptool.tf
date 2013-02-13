from flask import Flask

def _log_request(self):
    log = self.server.log
    if log:
        if hasattr(log, 'info'):
            log.info(self.format_request() + '\n')
        else:
            log.write(self.format_request() + '\n')

import gevent.pywsgi
gevent.pywsgi.WSGIHandler.log_request = _log_request

app = Flask(__name__)
app.config.from_pyfile('settings.py')

import comptool.views

from fabric.api import *

from os.path import expanduser

env.user = 'fabric'
env.hosts = ['comptool.tf']
env.key_filename = expanduser('~/.ssh/comptool.tf-deploy.key')

REMOTE_DIR = '/var/comptool.tf/'

def remote_setup():
    sudo('mkdir -p %s' % REMOTE_DIR)
    sudo('chown fabric %s' % REMOTE_DIR)
    with cd(REMOTE_DIR):
        run('git clone git://github.com/nickmeharry/comptool.tf.git .')
    run('virtualenv %s' % REMOTE_DIR)

def deploy():
    with cd(REMOTE_DIR), prefix('source bin/activate'):
        run('git reset --hard HEAD')
        run('git pull origin master')
        run('pip install -r requirements.txt')

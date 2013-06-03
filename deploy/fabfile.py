# coding: utf-8
from __future__ import unicode_literals
import sys
import os.path as op

from fabric.api import env, local, run, cd, lcd, settings, sudo
from fabric.colors import red, green
from fabric.contrib.files import exists

env.use_ssh_config = True
env.roledefs['vagrant'] = ["vagrant@127.0.0.1:2200"]

if not env.roles:
    print "No role specified, vagrant by default"
    env.roles = ['vagrant']

role = env.roles[0]
BASE_PATH = {
    'vagrant': '/opt/demo_django/www',
}[role]

def localsetup():
    print "Vagrant VM setup"
    with lcd(op.join('..', 'vagrant')):
        with settings(warn_only=True):
            result = local('vagrant status', capture=True)
            if result.return_code == 0 and 'running' in str(result):
                print "Vagrant is already running, no need to start it."
            else:
                local('vagrant up')
                # Yeah, we need to provision it once more. Our puppet script isn't perfect. :(
                local('vagrant provision')
                # Just once more to be sure...
                local('vagrant provision')
    if not op.exists(op.expanduser('~/.ssh/config')):
        print "Your file ~/.ssh/config doesn't exist but has to for the next command to work. Creating one now."
        with open(op.expanduser('~/.ssh/config'), 'wt') as fp:
            fp.write("IdentityFile ~/.ssh/id_rsa")
    local('ssh-add %s' % op.expanduser('~/.vagrant.d/insecure_private_key'))

def hostssetup():
    print green("Setting up, if needed, demo-django.local pointing to 127.0.0.1")
    if not op.exists('/etc/hosts'):
        print red("Your system has no /etc/hosts. You need to manually configure your system to make demo-django.local point to 127.0.0.1")
        return
    ETCHOSTS_LINE = "127.0.0.1 demo-django.local"
    if ETCHOSTS_LINE not in open('/etc/hosts', 'rt').read():
        print "Adding demo-django.local to /etc/hosts. Sudo required."
        local('echo "%s" | sudo tee -a /etc/hosts' % ETCHOSTS_LINE)
    else:
        print "Already done. Doing nothing."

def initialsetup():
    # SETTINGS_PATH referenced below was placed automatically by Puppet
    SETTINGS_PATH = op.join(op.dirname(BASE_PATH), 'settings.py')
    with cd(BASE_PATH):
        with cd('src/demo'):
            if not exists('settings_env.py'):
                run('ln -s %s settings_env.py' % SETTINGS_PATH)
        with cd('src'):
            run('../env/bin/python manage.py syncdb --noinput')
            run('../env/bin/python manage.py collectstatic --noinput')

def updateenv():
    with cd(BASE_PATH):
        if not exists('env'):
            print "No virtualenv present. Create it."
            run('virtualenv --system-site-packages env')
        run('./env/bin/pip install -r deploy/requirements.freeze')

def restart():
    SCRIPT_PATH = op.join(op.dirname(BASE_PATH), 'restart.sh')
    run('source %s' % SCRIPT_PATH)
    # Under vagrant, after the first provisionning, Apache is initially confused, so this is why
    # we restart it, but we normally don't have to do that.
    sudo('service apache2 restart')

def debugserver():
    print green("We're starting Django's built-in server. Access it through http://demo-django.local:8081")
    with cd(op.join(BASE_PATH, 'src')):
        run('../env/bin/python manage.py runserver 0.0.0.0:8080')

def deploy():
    localsetup()
    # If we wanted to support staging/production environements, we'd push our code through SSH right
    # about here, but since we have shared folders in your vagrant VM, we're not pushing anything.
    updateenv()
    initialsetup()
    restart()
    hostssetup()
    print green("Deployment complete! You can visit the website at http://demo-django.local:8080")
    print green("(Sometimes, right after a fresh deploy, apache is glitchy. If the URL doesn't respond, try running 'fab restart')")

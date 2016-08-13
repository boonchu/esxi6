#!/usr/bin/env python

from fabric.api import env
from fabric.operations import run, put

try:
    from fabfile_local import *
except ImportError, e:
    environments = {
            "esxi": {
                "hosts": ["esxi-a-01.example.com", "esxi-a-02.example.com"],
                },
            }
    print 'customize environment from fabfile_local.py (if any)'

def e(name='esxi'):
    print "Setting environment", name
    env.update(environments[name])
    env.environment = name
    env.shell = '/bin/sh -l -c'
    env.warn_only = True
    env.user = 'root'
    env.password = 'PASSWORD'

def install_vib():
    put('esxui-signed-4215448.vib', '/tmp')
    run('esxcli software vib install -v /tmp/esxui-signed-4215448.vib')

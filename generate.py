#!/usr/bin/env python

from __future__ import print_function
import os
import yaml
import errno


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


basedir =os.path.dirname(__file__)
with open(os.path.join(basedir, 'deps.yaml')) as f:
    data = yaml.load(f)


with open(os.path.join(basedir, 'CMakeLists.txt.template')) as f:
    cmake_template = f.read()
with open(os.path.join(basedir, 'package.xml.template')) as f:
    package_template = f.read()
with open(os.path.join(basedir, 'blacklist.txt')) as f:
    blacklist = set(f.read().splitlines())

for name, deps in data.items():
    if name in blacklist:
        continue
    for dep in deps:
        assert name != dep, "package that depends on itself: %s" % name
    base = os.path.join(basedir, name)
    mkdir_p(base)
    with open(os.path.join(base, 'CMakeLists.txt'), 'w') as out:
        out.write(cmake_template.format(name=name))
    with open(os.path.join(base, 'package.xml'), 'w') as out:
        dependencies = ['<exec_depend>' + d + '</exec_depend>' for d in deps]
        dependencies = '\n  '.join(dependencies)
        out.write(package_template.format(name=name, dependencies=dependencies))



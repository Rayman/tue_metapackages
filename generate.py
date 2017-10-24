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
cmake_hooks = '\ncatkin_add_env_hooks(${PROJECT_NAME} SHELLS sh DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/env-hooks)'

for name, deps in data.items():
    for dep in deps:
        assert name != dep, "package that depends on itself: %s" % name

    base = os.path.join(basedir, name)
    mkdir_p(base)

    with open(os.path.join(base, 'CMakeLists.txt'), 'w') as out:
        cmake = cmake_template.format(name=name)
        hook = None
        try:
            with open(os.path.join('setup', base)) as f:
                print('setup detected %s' % base)
                cmake += cmake_hooks
                hook = f.read()
        except IOError:
            pass
        else:
            hooks_dir = os.path.join(base, 'env-hooks')
            mkdir_p(hooks_dir)
            with open(os.path.join(hooks_dir, base + '.sh'), 'w') as f:
                f.write(hook)
        out.write(cmake)
    with open(os.path.join(base, 'package.xml'), 'w') as out:
        dependencies = ['<exec_depend>' + d + '</exec_depend>' for d in deps]
        dependencies = '\n  '.join(dependencies)
        out.write(package_template.format(name=name, dependencies=dependencies))



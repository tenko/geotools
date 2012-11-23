#!/usr/bin/python2
# -*- coding: utf-8 -*-
#
# This file is part of geotools - See LICENSE.txt
#
import sys
import os
import glob

from distutils.core import setup
from distutils.extension import Extension

try:
    from Cython.Distutils import build_ext
except ImportError:
    print >>sys.stderr, "Cython is required to build geotools"
    sys.exit(1)

#sys.argv.append('build_ext')
#sys.argv.extend(['sdist','--formats=gztar,zip'])
#sys.argv.append('bdist_wininst')

# create config file
sys.dont_write_bytecode = True
import version

CONFIG = 'geotools/@src/Config.pxi'
if not os.path.exists(CONFIG) and 'sdist' not in sys.argv:
    with open(CONFIG, 'w') as fh:
        fh.write("__version__ = '%s'\n" % version.STRING)
        args = version.MAJOR, version.MINOR, version.BUILD
        fh.write("__version_info__ = (%d,%d,%d)\n" % args)

classifiers = '''\
Development Status :: 5 - Production/Stable
Environment :: Console
Intended Audience :: Science/Research
License :: OSI Approved :: GNU General Public License v2 (GPLv2)
Operating System :: OS Independent
Programming Language :: Cython
Topic :: Scientific/Engineering :: Mathematics
'''

try:
    setup(
        name = 'geotools',
        version = version.STRING,
        description = 'Small geometry library',
        long_description = '''\
**geotools** is a small collection of geometrical classes
and functions accessable from both Python and Cython.

 * Point, Vector & Planes
 * Bounding box
 * Transformations
 * A camera class
''',
        classifiers = [value for value in classifiers.split("\n") if value],
        author='Runar Tenfjord',
        author_email = 'runar.tenfjord@gmail.com',
        license = 'GPLv2',
        download_url='http://pypi.python.org/pypi/geotools/',
        url = 'http://github.com/tenko/geotools',
        platforms = ['any'],
        
        ext_modules = [
            Extension("geotools",
                    sources = ["geotools/geotools.pyx",],
                    depends = glob.glob("geotools/@src/*.pxi") + \
                              glob.glob("geotools/@src/*.pxd") + \
                              glob.glob("geotools/@src/*.h"),
                    include_dirs = ['geotools/@src',],
            ),
        ],
      cmdclass = {'build_ext': build_ext},
    )
except:
    print('Traceback\n:%s\n' % str(sys.exc_info()[-2]))
    sys.exit(1)
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
from Cython.Distutils import build_ext

try:
    setup(
      name = 'geotools',
      ext_modules=[
        Extension("geotools",
                    sources=["geotools.pyx",],
                    depends = glob.glob("@src/*.pxi") + glob.glob("@src/*.pxd") + glob.glob("@src/*.h"),
                    include_dirs = ['@src',],
                    libraries = [],
        ),
        ],
        
      cmdclass = {'build_ext': build_ext}
    )
except:
    print('Traceback\n:%s\n' % str(sys.exc_info()[-2]))
    sys.exit(1)
else:
    print('\n')
Introduction
============

geotools is a small collection of geometrical classes
and functions accessable from both Python and Cython.

 * Point, Vector & Planes
 * Bounding box
 * Transformations
 * A camera class

Most of the code have been adapted from the openNURBS library (public domain).

The license is GPL v2.

Building
========

 * Python 2.7/3.x or later and Cython 0.17 or later.

Note that currently I can not find a way to install the required
Cython 'pxd' files with distutils and this file has to be copied
manually.

Prebuild installers are available on the pypi_ site
for the Windows platform.

Note that currently to be able to build the module on
Python 3.x the source must be patched. The '__div__'
member must be renamed to '__truediv__' and similar
for '__idiv__'.

Documentation
=============

See online Sphinx docs_

.. _docs: http://tenko.github.com/geotools/index.html

.. _pypi: http://pypi.python.org/pypi/geotools
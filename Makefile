#
# File:  Makefile (for library)
#
# The variables 'PYTHON' and 'PYVER' can be modified by
# passing parameters to make: make PYTHON=python PYVER=2.6
#
PYTHON=python2
PYVER=2.7

.PHONY: all docs test tests install clean

all:
	@echo lib Makefile - building python extension
	$(PYTHON) setup_build.py build_ext --inplace

docs: all
	@echo lib Makefile - building documentation
	@cd geotools/@docs ; $(PYTHON) ../../setup_docs.py build_sphinx
	@cp -rf geotools/@docs/build/sphinx/html/* geotools/@docs/html/
    
tests: all
	@echo lib Makefile - running test suite
	@cd geotools/@tests ; $(PYTHON) runAll.py

install: all
	@cp geotools.so ~/.local/lib/python$(PYVER)/site-packages/
	@cp geotools/geotools.pxd ~/.local/lib/python$(PYVER)/site-packages/

sdist: clean
	@echo lib Makefile - creating source distribution
	$(PYTHON) setup_build.py sdist --formats=gztar,zip
    
clean:
	-rm -rf build dist
	-rm -rf geotools/@docs/build
	-rm -rf geotools/@docs/html
	-rm geotools/@src/Config.pxi
	-rm geotools*.so geotools/geotools.c MANIFEST 
	-find geotools -iname '*.so' -exec rm {} \;
	-find geotools -iname '*.pyc' -exec rm {} \;
	-find geotools -iname '*.pyo' -exec rm {} \;
	-find geotools -iname '*.pyd' -exec rm {} \;
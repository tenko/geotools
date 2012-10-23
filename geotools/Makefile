#
# File:  Makefile (for library)
#
PYTHON=python2

.PHONY: all docs test tests install clean

all:
	@echo lib Makefile - building python extension
	$(PYTHON) setup_build.py build_ext --inplace
	-strip --strip-all geotools.so

docs: all
	@echo lib Makefile - building documentation
	@cd @docs ; $(PYTHON) ../setup_docs.py build_sphinx
	@cp -rf @docs/build/sphinx/html/* @docs/html/
    
tests: all
	@echo lib Makefile - running test suite
	@cd @tests ; $(PYTHON) runAll.py

install: all
	@cp geotools.so ~/.local/lib/python2.7/site-packages/
	@cp geotools.pxd ~/.local/lib/python2.7/site-packages/
    
clean:
	-rm -rf build
	-rm geotools.c
	-rm geotools.so
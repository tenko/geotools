#
# File:  Makefile for local builds
#
NAME=geotools
PYTHON=python3
PYVER=3.5
PYPREFIX=/mingw64
CC=gcc
INCLUDES=-I$(NAME)/@src -I$(PYPREFIX)/include/python$(PYVER)m
LIBS=-L@build -L$(PYPREFIX)/lib/python$(PYVERSION)

.PHONY: all docs test tests install clean

all: $(NAME)/@build/$(NAME)-cpython-$(PYVER)m.dll

$(NAME)/@build/$(NAME).c: $(NAME)/$(NAME).pyx $(NAME)/$(NAME).pxd $(NAME)/@src/*
	cython $(NAME)/$(NAME).pyx -I$(NAME)/@src -o $(NAME)/@build/$(NAME).c

$(NAME)/@build/$(NAME).o:	$(NAME)/@build/$(NAME).c
	$(CC) -c $(INCLUDES) $(NAME)/@build/$(NAME).c -o $(NAME)/@build/$(NAME).o

$(NAME)/@build/$(NAME)-cpython-$(PYVER)m.dll:	$(NAME)/@build/$(NAME).o
	$(CC) -shared $(NAME)/@build/$(NAME).o $(LIBS) -lpython$(PYVER)m -lm -o \
	$(NAME)/@build/$(NAME)-cpython-$(PYVER)m.dll

test: all
	@echo lib Makefile - running test suite
	PYTHONPATH=$(NAME)/@build $(PYTHON) $(NAME)/@tests/runAll.py

docs: all
	@echo lib Makefile - building documentation
	@cd $(NAME)/@docs ; $(PYTHON) ../../setup_docs.py build_sphinx
	@mkdir -p $(NAME)/@docs/html
	@cp -rf $(NAME)/@docs/build/sphinx/html/* $(NAME)/@docs/html/

install: all
	@cp $(NAME)/@build/$(NAME).* ~/.local/lib/python$(PYVER)/site-packages/

sdist: clean
	@echo lib Makefile - creating source distribution
	$(PYTHON) setup_build.py sdist --formats=gztar,zip
    
clean:
	-rm -rf build dist
	-rm -rf $(NAME)/@docs/build
	-rm -rf $(NAME)/@build/*
	-rm MANIFEST 
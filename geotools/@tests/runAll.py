# -*- coding: utf-8 -*-
#
# This file is part of geotools - See LICENSE.txt
#
import os
import unittest

if __name__ == '__main__':
    PATH = os.path.dirname(__file__)
    test_loader = unittest.defaultTestLoader.discover(PATH)
    test_runner = unittest.TextTestRunner(verbosity = 2)
    test_runner.run(test_loader)
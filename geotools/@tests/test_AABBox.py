#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# This file is part of geotools - See LICENSE.txt
#

import sys
import unittest
from math import pi, sqrt

from geotools import Point, Vector, AABBox
        
class test_AABBox(unittest.TestCase):
    def almostEqual(self, a, b, places = 7):
        for va,vb in zip(a,b):
            self.assertAlmostEqual(va, vb, places)
            
    def test_init(self):
        b1 = AABBox()
        
        self.assertTrue(b1.min == Point(-.5, -.5, -.5))
        self.assertTrue(b1.max == Point(.5, .5, .5))
        
        b2 = AABBox((-.5, -.5, -.5), (.5, .5, .5))
        
        self.almostEqual(b2.min, (-.5, -.5, -.5))
        self.almostEqual(b2.max, (.5, .5, .5))

    def test__eq__(self):
        b1 = AABBox()
        b2 = AABBox((-.5, -.5, -.5), (.5, .5, .5))
        
        self.assertTrue(b1 == b2)
        self.assertTrue(not b1 != b2)
    
    def test__ne__(self):
        b1 = AABBox()
        b2 = AABBox((-1., -1., -1.), (1., 1., 1.))
        
        self.assertTrue(b1 != b2)
        self.assertTrue(not b1 == b2)
    
    def test_valid(self):
        b1 = AABBox((-1., -1., -1.), (1., 1., 1.))
        
        self.assertTrue(b1.isValid())
        
        b2 = AABBox((1., 1., 1.), (-1., -1., -1.))
        
        self.assertTrue(not b2.isValid())
    
    def test_diagonal(self):
        b1 = AABBox((-.5, -.5, -.5), (.5, .5, .5))
        
        self.almostEqual(b1.diagonal, (1.0, 1.0, 1.0))
    
    def test_center(self):
        b1 = AABBox((-.5, -.5, -.5), (.5, .5, .5))
        
        self.almostEqual(b1.center, (0., 0., 0.))
    
    def test_radius(self):
        b1 = AABBox((-.5, -.5, -.5), (.5, .5, .5))
        
        self.assertAlmostEqual(b1.radius, .5*sqrt(3))
    
    def test_volume(self):
        b1 = AABBox((-.5, -.5, -.5), (.5, .5, .5))
        
        self.assertAlmostEqual(b1.volume, 1.)
    
    def test_isPointIn(self):
        b1 = AABBox((-.5, -.5, -.5), (.5, .5, .5))
        
        self.assertTrue(b1.isPointIn((0.,0.,0.)))
        self.assertTrue(not b1.isPointIn((1.,1.,1.)))
        self.assertTrue(b1.isPointIn((-.5, .5, -.5)))
        self.assertTrue(not b1.isPointIn((-.5, .5, -.5), strictlyIn = True))
    
    def test_addPoint(self):
        b1 = AABBox((-.5, -.5, -.5), (.5, .5, .5))
        
        b1.addPoint((-1., 1., -1.))
        b1.addPoint((1., -1., 1.))
        
        self.almostEqual(b1.min, (-1., -1., -1.))
        self.almostEqual(b1.max, (1., 1., 1.))
    
    def test_addPoints(self):
        b1 = AABBox((-.5, -.5, -.5), (.5, .5, .5))
        
        b1.addPoints(((-1., 1., -1.), (1., -1., 1.)))
        
        self.almostEqual(b1.min, (-1., -1., -1.))
        self.almostEqual(b1.max, (1., 1., 1.))
        
if __name__ == "__main__":
    sys.dont_write_bytecode = True
    unittest.main()
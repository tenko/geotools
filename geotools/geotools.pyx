# -*- coding: utf-8 -*-
#cython: embedsignature=True
#
# This file is part of geotools - See LICENSE.txt
#
from libc.stdlib cimport malloc, free

from libc.math cimport fabs, copysign
from libc.math cimport M_PI, sqrt, sin, cos, tan
    
cimport cpython.array

# math constants
cdef double EPSILON = 2.2204460492503131e-16
cdef double SQRT_EPSILON = 1.490116119385000000e-8
cdef double ZERO_TOLERANCE = 1.0e-12
cdef double DEFAULT_ANGLE_TOLERANCE = M_PI/180.

class GeoError(Exception):
    pass

include "Config.pxi"
include "AABBox.pxi"
include "Camera.pxi"
include "Plane.pxi"
include "Point.pxi"
include "Quaternion.pxi"
include "Transform.pxi"
include "Vector.pxi"
include "Utilities.pxi"
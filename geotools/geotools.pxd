# -*- coding: utf-8 -*-
#
# This file is part of geotools - See LICENSE.txt
#

cdef class AABBox:
    cdef public Point min
    cdef public Point max
    
    cpdef bint isValid(self)
    cpdef invalidate(self)
    cpdef bint isPointIn(self, pnt, bint strictlyIn = ?)
    cpdef addPoint(self, pnt)
    cpdef addPoints(self, pnts)

cdef class Camera:
    cdef public int projection
    
    cdef public Point loc
    cdef public Vector dir
    cdef public Vector up
    cdef public Vector X
    cdef public Vector Y
    cdef public Vector Z
    
    cdef public double fvLeft
    cdef public double fvRight
    cdef public double fvBottom
    cdef public double fvTop
    cdef public double fvNear
    cdef public double fvFar
    
    cdef public int scrLeft
    cdef public int scrRight
    cdef public int scrBottom
    cdef public int scrTop
    cdef public double scrNear
    cdef public double scrFar
    
    cdef public Point target
    
    cpdef updateFrame(self)
    cpdef setAngle(self, double angle)
    cpdef setFrustumNearFar(self, double n, double f)
    cpdef setFrustumAspect(self, double frustum_aspect)
    cpdef setViewportSize(self, int width, int height)
    cpdef Vector getDollyVector(self, int x0, int y0, int x1, int y1,
                                double distance_to_camera)
    cpdef rotate(self, double angle, Vector axis, Point center = ?)
    cpdef rotateDeltas(self, double dx, double dy, double speed = ?, Point target = ?)
    cpdef pan(self, int lastx, int lasty, int x, int y, Point target = ?)
    cpdef zoomFactor(self, double magnification_factor, fixed_screen_point = ?)
    cpdef zoomExtents(self, Point near, Point far, double angle = ?)
    cpdef setTopView(self)
    cpdef setBottomView(self)
    cpdef setLeftView(self)
    cpdef setRightView(self)
    cpdef setFrontView(self)
    cpdef setBackView(self)
    cpdef setIsoView(self)

cdef class Point:
    cdef public double x, y, z
    cpdef bint isZero(self)
    cpdef int maximumCoordinateIndex(self)
    cpdef double maximumCoordinate(self)
    cpdef double distanceTo(self, Point arg)

cpdef double distance(Point u, Point v)

cdef class Plane:
    cdef readonly Point origin
    cdef readonly Vector xaxis
    cdef readonly Vector yaxis
    cdef readonly Vector zaxis
    
    cdef readonly double a
    cdef readonly double b
    cdef readonly double c
    cdef readonly double d
    
    cpdef double ValueAt(self, pnt)
    cpdef _UpdateEquation(self)
    cpdef double distanceTo(self, pnt)
    cpdef Point closestPoint(self, pnt)
    cpdef intersectLine(self, start, end)
    cpdef flip(self)
    cpdef transform(self, Transform trans)
    
    
cdef class Quaternion:
    cdef public double w, x, y, z
    cpdef Quaternion unit(self)
    cpdef Quaternion conj(self)

cdef class Transform:
    cdef double m[4][4]
    # buffer interface
    cdef Py_ssize_t __shape[2]
    cdef Py_ssize_t __strides[2]
    cdef __cythonbufferdefaults__ = {"ndim": 2, "mode": "c"}
    cpdef Transform zero(self)
    cpdef Transform identity(self)
    cpdef double det(self)
    cpdef Transform transpose(self)
    cpdef Transform invert(self)
    cpdef Transform rotateX(self, double x)
    cpdef Transform rotateY(self, double y)
    cpdef Transform rotateZ(self, double z)
    cpdef Transform rotateAxisCenter(self, double angle, _axis, _center = ?)
    cpdef Transform worldToCamera(self, Camera cam)
    cpdef Transform cameraToWorld(self, Camera cam)
    cpdef clipToCamera(self, Camera cam)
    cpdef cameraToClip(self, Camera cam)

cdef class Vector(Point):
    cpdef Vector unit(self)

cpdef double dot(Vector a, Vector b)
cpdef Vector cross(Vector a, Vector b)
cpdef int isParallell(Vector v1, Vector v2)
cpdef bint isPerpendicular(Vector v1, Vector v2)
cpdef Vector perpendicular(Vector v)

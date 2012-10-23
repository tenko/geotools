# -*- coding: utf-8 -*-
#
# This file is part of geotools - See LICENSE.txt
#
cdef class AABBox:
    '''
    Class representing an Axis Aligned Bounding Box
    '''
    def __init__(self, min = (-.5, -.5, -.5), max = (.5, .5, .5)):
        self.min = Point(min)
        self.max = Point(max)
        
    def __repr__(self):
        """Return string representation of a box.
        """
        return '(min = %s, max = %s)' % (str(self.min), str(self.max))
    
    def __str__(self):
        """Return string representation of a box.
        """
        return '%s%s' % (self.__class__.__name__, repr(self))
    
    def __richcmp__(a, b, int op):
        """Rich comparison self == other & self != other"""
        cdef AABBox pa, pb
        
        if (not isinstance(a, AABBox) or not isinstance(b, AABBox)):
            if op==3:
                return 1
            else:
                return 0
                
        pa = a
        pb = b
        
        # ==
        if op == 2:
            return pa.min == pb.min and pa.max == pb.max
        elif op == 3:
            return pa.min != pb.min and pa.max != pb.max
        else:
            raise NotImplementedError()
    
    cpdef bint isValid(self):
        """Check validity
        """
        return self.min.x <= self.max.x and self.min.y <= self.max.y and self.min.z <= self.max.z
    
    cpdef invalidate(self):
        '''
        Set bounding box in invalid state.
        '''
        self.min.set(1.e100, 1.e100, 1.e100)
        self.max.set(-1.e100, -1.e100, -1.e100)
       
    property diagonal:
        'Return diagonal as a vector'
        def __get__(self):
            return Vector(self.max - self.min)
    
    property center:
        'Calculate center of box'
        def __get__(self):
            return .5*(self.min + self.max)
    
    property radius:
        'Return radius of the sphere enclosing the box'
        def __get__(self):
            return .5 *sqrt(3. * fmax3(self.max.x - self.min.x, self.max.y - self.min.y, self.max.z - self.min.z) ** 2.)
    
    property volume:
        'Calculate volume of box'
        def __get__(self):
            cdef double dx, dy, dz
            
            if self.isValid():
                dx = self.max.x - self.min.x
                dy = self.max.y - self.min.y
                dz = self.max.z - self.min.z
                
                return fabs(dx * dy * dz)
            else:
                return 0.
    
    cpdef bint isPointIn(self, pnt, bint strictlyIn = False):
        '''
        Check if point is inside box.
        '''
        cdef double x, y, z
        x, y, z = pnt
        
        if strictlyIn:
            return self.min.x < x and x < self.max.x and \
                   self.min.y < y and y < self.max.y and \
                   self.min.z < z and z < self.max.z 
        else:
            return self.min.x <= x and x <= self.max.x and \
                   self.min.y <= y and y <= self.max.y and \
                   self.min.z <= z and z <= self.max.z 
        
    cpdef addPoint(self, pnt):
        """
        Adjust bounds to include point.
        """
        cdef double x, y, z
        
        x, y, z = pnt
        
        self.min.x = fmin(self.min.x, x)
        self.min.y = fmin(self.min.y, y)
        self.min.z = fmin(self.min.z, z)
        
        self.max.x = fmax(self.max.x, x)
        self.max.y = fmax(self.max.y, y)
        self.max.z = fmax(self.max.z, z)
    
    cpdef addPoints(self, pnts):
        """
        Adjust bounds to include point.
        """
        cdef double x, y, z
        
        for pnt in pnts:
            x, y, z = pnt
            
            self.min.x = fmin(self.min.x, x)
            self.min.y = fmin(self.min.y, y)
            self.min.z = fmin(self.min.z, z)
            
            self.max.x = fmax(self.max.x, x)
            self.max.y = fmax(self.max.y, y)
            self.max.z = fmax(self.max.z, z)
    
    @classmethod
    def union(cls, AABBox a, AABBox b):
        """Return a new bounding box which is a union of
            the arguments.
        """
        cdef AABBox c = AABBox.__new__(AABBox)
        
        if a.isValid() and b.isValid():
            c.min = Point(*b.min)
            c.max = Point(*b.max)
            
            if a.min.x <= b.min.x: c.min.x = a.min.x
            if a.min.y <= b.min.y: c.min.y = a.min.y
            if a.min.z <= b.min.z: c.min.z = a.min.z
            
            if a.max.x >= b.max.x: c.max.x = a.max.x
            if a.max.y >= b.max.y: c.max.y = a.max.y
            if a.max.z >= b.max.z: c.max.z = a.max.z
        return c
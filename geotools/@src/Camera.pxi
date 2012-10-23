# -*- coding: utf-8 -*-
#
# This file is part of geotools - See LICENSE.txt
#

MIN_NEAR_DIST = 0.0001
MIN_NEAR_OVER_FAR = 0.0001
PARALLEL, PROJECTED = 1, 2
    
cdef class Camera:
    '''
    Modify the Loc, Dir & Up variables and then call *updateCameraFrame*
    to set the up the camera frame vectors.
    
    :projection: PARALLEL or PROJECTED projection type
    :Loc: camera location
    :Dir: from camera towards view (nonzero and not parallel to up)
    :Up: (nonzero and not parallel to m_CamDir)
    :X: camera frame X vector
    :Y: camera frame Y vector
    :Z: camera frame Z vector
    :target: fixed point used in camera rotations and camera dolly operations.
    '''
    def __init__(self, projection = PARALLEL):
        self.projection = projection
        
        self.Loc = Point(0.,0.,100.)
        self.Dir = Vector(0., 0., -1.)
        self.Up = Vector(0., 1., 0.)
        self.X = Vector(1., 0., 0.)
        self.Y = Vector(0., 1., 0.)
        self.Z = Vector(0., 0., 1.)
        
        self.fvLeft = -20.
        self.fvRight = 20.
        self.fvBottom = -20.
        self.fvTop = 20.
        self.fvNear = MIN_NEAR_DIST
        self.fvFar = 100.
        
        self.scrLeft = 0
        self.scrRight = 1000
        self.scrBottom = 0
        self.scrTop = 1000
        self.scrNear = 0
        self.scrFar = 1
        
        self.target = Point(0.,0.,0.)
    
    cpdef updateCameraFrame(self):
        # Calculate camera frame
        cdef Vector Z = -self.Dir
        Z.unit()
        
        cdef double d = dot(self.Up, Z)
        cdef Vector Y = self.Up - d * Z
        Y.unit()
        
        cdef Vector X = cross(Y, Z)
        
        self.X = X
        self.Y = Y
        self.Z = Z
    
    cpdef setCameraAngle(self, double angle):
        cdef double d, aspect
        cdef double w, h, half_w, half_d
        
        if angle < 0. or angle > .5*M_PI*(1. - SQRT_EPSILON):
            return
        
        d = self.fvNear*tan(angle)
        
        w = self.fvRight - self.fvLeft
        h = self.fvTop - self.fvBottom
        aspect = float(w) / h
        
        if aspect >= 1.:
            # width >= height
            half_w = d*aspect
            half_h = d
        else:
            # height > width
            half_w = d
            half_h = d/aspect
        
        self.fvLeft, self.fvRight = -half_w, half_w
        self.fvBottom, self.fvTop  = -half_h, half_h
    
    cpdef setFrustumNearFar(self, double n, double f):
        cdef double d
        
        if self.projection == PROJECTED:
            d = n/self.fvNear
            self.fvLeft *= d
            self.fvRight *= d
            self.fvBottom *= d
            self.fvTop *= d
        
        self.fvNear, self.fvFar = n, f
        
    cpdef setFrustumAspect(self, double frustum_aspect):
        '''
        setFrustumAspect() changes the larger of the frustum's widht/height
        so that the resulting value of width/height matches the requested
        aspect.  The camera angle is not changed.  If you change the shape
        of the view port with a call setViewportSize(), then you generally 
        want to call SetFrustumAspect().
        '''
        assert frustum_aspect > 0, 'frustum aspect < 0.'
        
        cdef double w = self.fvRight - self.fvLeft
        cdef double h = self.fvTop - self.fvBottom
        cdef double d = 0.
        
        if abs(h) > abs(w):
            d = abs(w) if h > 0. else -abs(w)
            d *= .5
            h = .5*(self.fvTop + self.fvBottom)
            self.fvBottom = h - d
            self.fvTop = h + d
            h = self.fvTop - self.fvBottom
        else:
            d = abs(h) if w > 0. else -abs(h)
            d *= .5
            w = .5*(self.fvLeft + self.fvRight)
            self.fvLeft  = w - d
            self.fvRight = w + d
            w = self.fvRight - self.fvLeft
        
        if frustum_aspect > 1.0:
            # increase width
            d = .5*w*frustum_aspect
            w = .5*(self.fvLeft + self.fvRight)
            self.fvLeft = w - d
            self.fvRight = w + d
            w = self.fvRight - self.fvLeft
        
        elif frustum_aspect < 1.0:
            # increase height
            d = .5*h/frustum_aspect
            h = .5*(self.fvBottom + self.fvTop)
            self.fvBottom = h - d
            self.fvTop = h + d
            h = self.fvTop - self.fvBottom
        
    cpdef setViewportSize(self, int width, int height):
        '''
        Location of viewport in pixels.
        These are provided so you can set the port you are using
        and get the appropriate transformations to and from
        screen space.
        '''
        self.scrLeft = 0
        self.scrRight = width
        self.scrBottom = height
        self.scrTop = 0
        self.scrNear = 0
        self.scrFar = 0xff
    
    cpdef Vector getDollyCameraVector(self, int x0, int y0, int x1, int y1,
                                      double distance_to_camera):
        '''
        Get camera dolly vector for the given screen coordinates
        '''
        cdef Transform tr
        tr = Transform().cameraToWorld(self) * Transform().clipToCamera(self)
        
        cdef double dx = .5*(self.scrRight - self.scrLeft)
        cdef double dy = .5*(self.scrTop - self.scrBottom)
        cdef double dz = .5*(self.fvFar - self.fvNear)
        
        cdef double z = (distance_to_camera - self.fvNear)/dz - 1.
        c0 = Point((x0 - self.scrLeft)/dx - 1., (y0 - self.scrBottom)/dy - 1., z)
        c1 = Point((x1 - self.scrLeft)/dx - 1., (y1 - self.scrBottom)/dy - 1., z)
        w0 = Vector(*tr.map(c0))
        w1 = Vector(*tr.map(c1))
        
        return w0 - w1
        
    cpdef rotateCamera(self, double angle, Vector axis, Point center = None):
        '''
        Rotate camera and update frame.
        '''
        cdef Transform rot = Transform()
        
        if center is None:
            center = self.Loc
            
        rot.rotateAxisCenter(angle, axis, center)
        
        self.Loc.set(rot.map(self.Loc))
        self.Dir.set(rot.map(-self.Z))
        self.Up.set(rot.map(self.Y))
        self.updateCameraFrame()
        
    cpdef zoomFactor(self, double magnification_factor, fixed_screen_point = None):
        cdef Point dpnt
        cdef double fx, fy, dx, dy
        cdef double w0 = self.fvRight - self.fvLeft
        cdef double h0 = self.fvTop - self.fvBottom
        cdef double min_target_distance
        cdef double delta, d = 0.
        
        cdef int scr_width  = self.scrRight - self.scrLeft
        cdef int scr_height = self.scrBottom - self.scrTop
        
        
        if magnification_factor <= 0. or scr_width == 0 or scr_height == 0:
            return
        
        if not fixed_screen_point is None:
            pnt = fixed_screen_point
            if pnt[0] <= 0. or pnt[0] >= scr_width -1:
                fixed_screen_point = None
            
            if pnt[1] <= 0 or pnt[1] >= scr_height -1:
                fixed_screen_point = None
        
        if self.projection == PROJECTED:
            min_target_distance = 1.0e-6
            target_distance = dot((self.Loc - self.target), self.Z)
            if target_distance >= 0.:
                delta = (1. - 1./magnification_factor)*target_distance
                if target_distance-delta > min_target_distance:
                    self.self.Loc -= Point(delta*self.Z)
                    if not fixed_screen_point is None:
                        d = target_distance/self.fvNear;
                        w0 *= d;
                        h0 *= d;
                        d = (target_distance - delta)/target_distance
        
        else:
            # parallel proj or "true" zoom
            # apply magnification to frustum
            d = 1./magnification_factor
            self.fvLeft   *= d
            self.fvRight  *= d
            self.fvBottom *= d
            self.fvTop    *= d
        
        if not fixed_screen_point is None and d != 0.: 
            # lateral dolly to keep fixed_screen_point 
            # in same location on screen
            fx = fixed_screen_point[0]/float(scr_width)
            fy = fixed_screen_point[1]/float(scr_height)
            dx = (.5 - fx)*(1. - d)*w0
            dy = (fy - .5)*(1. - d)*h0
            
            dpnt = dx*self.X + dy*self.Y
            self.target -= dpnt
            self.Loc -= dpnt
            
    cpdef zoomExtents(self, Point near, Point far, double angle = 15.*M_PI/180.):
        cdef Vector vec = Vector(0.,0.,0.)
        cdef Point center = .5*(near + far)
        cdef double target_dist, near_dist, far_dist
        cdef double xmin, ymin, xmax, ymax
        cdef double x, y, z, x0, y0, radius
        
        xmin = ymin = 1.e99
        xmax = ymax = -1.e99
        
        for x in (near.x, far.x):
            for y in (near.y, far.y):
                for z in (near.z, far.z):
                    vec.set(x, y, z)
                    x0 = dot(self.X, vec)
                    y0 = dot(self.Y, vec)
                    
                    xmin = min(xmin, x)
                    ymin = min(ymin, y)
                    xmax = max(xmax, x)
                    ymax = max(ymax, y)
                    
        radius = xmax - xmin
        if ymax - ymin > radius:
            radius = ymax - ymin
        
        radius *= .5
        if radius <= SQRT_EPSILON:
            radius = 1.
        
        target_dist = radius/sin(angle)
        if self.projection != PROJECTED:
            target_dist += 1.0625*radius
        
        near_dist = target_dist - 1.0625*radius
        if near_dist < 0.0625*radius:
            near_dist = 0.0625*radius
            
        if near_dist < MIN_NEAR_DIST:
            near_dist = MIN_NEAR_DIST
        
        far_dist = target_dist + 1.0625*radius
        self.Loc = center + target_dist*self.Z
        self.setFrustumNearFar(near_dist, far_dist)
        
        self.setCameraAngle(angle)
        
        # FIXME! - Use calculated distances!
        self.fvNear, self.fvFar = 0.01, 10000.
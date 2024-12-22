//
//  VectorExtensions.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/26/24.
//

import SceneKit

public extension SCNVector3 {
    func length() -> CGFloat {
        return sqrt(x * x + y * y + z * z)
    }
    
    var vectorLen : CGFloat {
        return sqrt(x * x + y * y + z * z)
    }
    
    func normalized() -> SCNVector3 {
        let len = length()
        return SCNVector3(x / len, y / len, z / len)
    }
    
    var normalizedVec : SCNVector3 {
        return normalized()
    }
    
    func distance(to: SCNVector3) -> CGFloat {
        let diff = self.subtracted(by: to)
        return diff.vectorLen
    }
    
    func scaleBy(_ factor: CGFloat) -> SCNVector3 {
        return SCNVector3(x * factor, y * factor, z * factor)
    }
    
    func extendBy(by length: CGFloat) -> SCNVector3 {
        let norm = normalized()
        let extended = norm.scaleBy(length)
        return SCNVector3(x + extended.x, y + extended.y, z + extended.z)
    }
    
    func extendTo(to length: CGFloat) -> SCNVector3 {
        let norm = normalized()
        let extended = norm.scaleBy(length)
        return extended
    }
    
    var azimuthElevation: (azimuth: CGFloat, elevation: CGFloat) {
        let az = atan2(z, x)
        let el = asin(y / length())
        return (az, el)
    }

    func quaternion(fromAngleRadians: CGFloat) -> SCNQuaternion {
        // See:
        // https://www.youtube.com/watch?v=zjMuIxRvygQ
        // http://sacredsoftware.net/tutorials/quaternion.html
        
        // For a better explanation as to why the angle is halved, see:
        // https://eater.net/quaternions/
        let halfAngle = fromAngleRadians * 0.5
        let sinAngle: CGFloat = sin(halfAngle)
        
        let axis = self.normalized()
        
        // Recall that a quaternion can be expressed as:
        // cos(angle) + sin(angle) * (x + y + z)
        // Which expands to:
        // cos(a) + sin(a)x + sin(a)y + sin(a)z
        // The cos(a) is our real component (W)
        
        return SCNQuaternion(x: axis.x * sinAngle,
                             y: axis.y * sinAngle,
                             z: axis.z * sinAngle,
                             w: cos(halfAngle))
    }
}

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
    
    func normalized() -> SCNVector3 {
        let len = length()
        return SCNVector3(x / len, y / len, z / len)
    }
    
    func scaleBy(_ factor: CGFloat) -> SCNVector3 {
        return SCNVector3(x * factor, y * factor, z * factor)
    }
}

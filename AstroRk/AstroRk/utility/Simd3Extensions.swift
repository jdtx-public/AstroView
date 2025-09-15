//
//  Simd3Extensions.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/19/24.
//

import Foundation
import simd

public extension simd_double3 {
    var kmToEarthRadii : simd_double3 {
        return self / AstroConstants.oneEarthRadiusInKm
    }
    
    var earthRadiiToViewUnits : simd_double3 {
        return (self * 0.2) / 109.0
    }
    
    var float: simd_float3 {
        return simd_float3(x: Float(self.x), y: Float(self.y), z: Float(self.z))
    }
}

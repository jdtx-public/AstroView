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
}

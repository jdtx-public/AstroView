//
//  FloatExtensions.swift
//  AstroRk
//
//  Created by Jeff Doar on 9/14/25.
//

import Foundation

public extension Float {
    var kmToViewUnits : Float {
        return (self / 695700.0) * 0.2
    }
}

public extension Double {
    var earthRadiiToViewUnits: Double {
        // sun radius = 0.2 world units
        return (self / 109.0) * 0.2
    }
}

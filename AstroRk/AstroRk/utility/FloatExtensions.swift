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

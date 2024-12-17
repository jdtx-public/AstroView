//
//  SystemModel.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/16/24.
//

import Foundation
import simd

public protocol SystemModel {
    func forEachBody(_ body: (BodyRecord) throws -> Void) throws
    
    func sunRelativePosition(forBody body: BodyRecord, atTime time: Date) -> simd_double3
}

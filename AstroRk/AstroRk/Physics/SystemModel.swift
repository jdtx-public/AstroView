//
//  SystemModel.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/16/24.
//

import Foundation
import simd

public protocol SystemModel {
    var bodyCatalog : BodyCatalog { get }
    
    func sunRelativePosition(forBody body: BodyRecord, atTime time: Date) -> simd_double3
}

public extension SystemModel {
    func parentRelativePosition(forBody body: BodyRecord, atTime time: Date) -> simd_double3 {
        let parentBody = bodyCatalog.parentBody(for: body)
        
        if (parentBody == nil) {
            return simd_double3.zero
        }
        
        let parentPosition = sunRelativePosition(forBody: parentBody!, atTime: time)
        let thisPosition = sunRelativePosition(forBody: body, atTime: time)
        
        return thisPosition - parentPosition
    }
}

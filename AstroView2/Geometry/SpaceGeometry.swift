//
//  GeometryFactory.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/20/24.
//

import Foundation
import SceneKit

public protocol SpaceGeometry {
    func createGeometry() throws -> SCNNode
}

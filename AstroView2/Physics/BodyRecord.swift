//
//  BodyRecord.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/16/24.
//

import Foundation

public class BodyRecord {
    public let name: String
    public let path: String
    public let earthRadiusFraction: Double
    public let texturePath: String
    
    public init(name: String, path: String, earthRadiusFraction: Double, texturePath: String) {
        self.name = name
        self.path = path
        self.earthRadiusFraction = earthRadiusFraction
        self.texturePath = texturePath
    }
    
}

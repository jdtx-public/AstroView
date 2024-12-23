//
//  SpiceSystemModel.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/16/24.
//

import Foundation
import simd
import cspice_swift

public class SpiceSystemModel : SystemModel {
    private let _bodyRecords: [BodyRecord]
    private let _solarSystem: SolarSystem
    private let _kernels: [Kernel]

    public init() {
        let mainBundle = Bundle.main
        
        let bsps = [ "de432s", "de438", "de440" ]
        
        let resourcePaths : [String] = bsps.map { mainBundle.path(forResource: $0, ofType: "bsp", inDirectory: "spice")! }

        var localKernels : [Kernel] = resourcePaths.map { Kernel(withFilePath: $0) }
        
        _kernels = localKernels
        _solarSystem = SolarSystem()
        
        _bodyRecords = SpiceSystemModel.createBodyRecords()
    }
    
    public func forEachBody(_ body: (BodyRecord) throws -> Void) throws {
        try _bodyRecords.forEach { try body($0) }
    }
    
    public func sunRelativePosition(forBody body: BodyRecord, atTime time: Date) -> simd_double3 {
        let planetBody = _solarSystem[body.name]!

        // spice gives answers in KM; we expect answers in earth radii
        let posKm = planetBody.solarPosition(atDate: time)
        
        return posKm.kmToEarthRadii
    }
    
    private class func createBodyRecords() -> [BodyRecord] {
        let records : [BodyRecord] = [
            BodyRecord(name: "Sun", path: ":", earthRadiusFraction: 109, texturePath: "Solarsystemscope_texture_8k_sun"),
            BodyRecord(name: "Mercury", path: ":Sun:", earthRadiusFraction: 0.3829, texturePath: "Solarsystemscope_texture_8k_mercury"),
            BodyRecord(name: "Venus", path: ":Sun:", earthRadiusFraction: 0.3829, texturePath: "2k_venus_surface"),
            BodyRecord(name: "Earth", path: ":Sun:", earthRadiusFraction: 1, texturePath: "Solarsystemscope_texture_8k_earth_daymap"),
            /*
            BodyRecord(name: "Mars", path: ":Sun:", earthRadiusFraction: 0.533, texturePath: "2k_mars"),
            BodyRecord(name: "Jupiter", path: ":Sun:", earthRadiusFraction: 11.21, texturePath: "2k_jupiter"),
            BodyRecord(name: "Saturn", path: ":Sun:", earthRadiusFraction: 9.45, texturePath: "2k_saturn"),
            BodyRecord(name: "Uranus", path: ":Sun:", earthRadiusFraction: 4.01, texturePath: "2k_uranus"),
            BodyRecord(name: "Neptune", path: ":Sun:", earthRadiusFraction: 3.88, texturePath: "2k_neptune"),
            */
        ]
        
        return records
    }
}

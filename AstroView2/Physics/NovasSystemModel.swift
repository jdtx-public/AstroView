//
//  NovasSystemModel.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/16/24.
//

import Foundation
import simd
import novas_swift

public class NovasSystemModel: SystemModel {
    private let _planetSim: PlanetSim
    private let _bodyRecords: [BodyRecord]
    
    public init() {
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: "lnxp1900p2053", ofType: "421", inDirectory: "ephemeris")!
        
        _planetSim = PlanetSim(ephemerisPath: resourcePath)
        
        _bodyRecords = NovasSystemModel.createBodyRecords()
    }
    
    public func forEachBody(_ body: (BodyRecord) throws -> Void) throws {
        try _bodyRecords.forEach { try body($0) }
    }
    
    public func sunRelativePosition(forBody body: BodyRecord, atTime time: Date) -> simd_double3 {
        switch body.name {
        case "Sun":
            return _planetSim.sunPos(d: time)
        case "Mercury":
            return _planetSim.mercuryPos(d: time)
        case "Venus":
            return _planetSim.venusPos(d: time)
        case "Earth":
            return _planetSim.earthPos(d: time)
        case "Mars":
            return _planetSim.marsPos(d: time)
        case "Jupiter":
            return _planetSim.jupiterPos(d: time)
        case "Saturn":
            return _planetSim.saturnPos(d: time)
        case "Uranus":
            return _planetSim.uranusPos(d: time)
        case "Neptune":
            return _planetSim.neptunePos(d: time)
        default:
            return simd_double3.zero
        }
    }
    
    private class func createBodyRecords() -> [BodyRecord] {
        let records : [BodyRecord] = [
            BodyRecord(name: "Sun", path: ":", earthRadiusFraction: 109, texturePath: "Solarsystemscope_texture_8k_sun", orbitalPeriodEarthYears: 0.0),
            BodyRecord(name: "Mercury", path: ":Sun:", earthRadiusFraction: 0.3829, texturePath: "Solarsystemscope_texture_8k_mercury", orbitalPeriodEarthYears: 0.2408467),
            BodyRecord(name: "Venus", path: ":Sun:", earthRadiusFraction: 0.3829, texturePath: "2k_venus_surface", orbitalPeriodEarthYears: 0.61519726),
            BodyRecord(name: "Earth", path: ":Sun:", earthRadiusFraction: 1, texturePath: "Solarsystemscope_texture_8k_earth_daymap", orbitalPeriodEarthYears: 1.0000174),
            BodyRecord(name: "Mars", path: ":Sun:", earthRadiusFraction: 0.533, texturePath: "2k_mars", orbitalPeriodEarthYears: 1.8808476),
            BodyRecord(name: "Jupiter", path: ":Sun:", earthRadiusFraction: 11.21, texturePath: "2k_jupiter", orbitalPeriodEarthYears: 11.862615),
            BodyRecord(name: "Saturn", path: ":Sun:", earthRadiusFraction: 9.45, texturePath: "2k_saturn", orbitalPeriodEarthYears: 29.447498),
            BodyRecord(name: "Uranus", path: ":Sun:", earthRadiusFraction: 4.01, texturePath: "2k_uranus", orbitalPeriodEarthYears: 84.016846),
            BodyRecord(name: "Neptune", path: ":Sun:", earthRadiusFraction: 3.88, texturePath: "2k_neptune", orbitalPeriodEarthYears: 164.79132),
        ]
        
        return records
    }
}

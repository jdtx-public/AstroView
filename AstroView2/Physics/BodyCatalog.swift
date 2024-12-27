//
//  BodyCatalog.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/26/24.
//

import Foundation

public class BodyCatalog {
    private let _bodies : [String : BodyRecord]
    
    public init() {
        let bodyArr = BodyCatalog.createBodyRecords( )
        
        _bodies = bodyArr.reduce(into: [String : BodyRecord]()) {
            $0[$1.name] = $1
        }
    }
    
    func parentBody(for body: BodyRecord) -> BodyRecord? {
        if body.name == "Sun" {
            return nil
        }
        
        let parentBodyName = body.path
        
        if (parentBodyName.isEmpty == true) {
            return nil
        }
        
        if _bodies.contains(where: { $0.value.name == parentBodyName }) {
            return _bodies[parentBodyName]
        }
        
        return nil
    }
    
    func forEachChild(of body: BodyRecord, _ callback: (BodyRecord) throws -> Void) throws {
        try _bodies
            .filter { $0.value.path == body.name }
            .forEach { try callback($0.value) }
    }
    
    func forEachBody(_ body: (BodyRecord) throws -> Void) throws {
        try _bodies.forEach { try body($0.value) }
    }
    
    public var sun : BodyRecord {
        return _bodies["Sun"]!
    }

    private class func createBodyRecords() -> [BodyRecord] {
        let records : [BodyRecord] = [
            BodyRecord(name: "Sun", path: "", earthRadiusFraction: 109, texturePath: "Solarsystemscope_texture_8k_sun", orbitalPeriodEarthYears: 0.0, bodyType: .Sun),
            BodyRecord(name: "Mercury", path: "Sun", earthRadiusFraction: 0.3829, texturePath: "Solarsystemscope_texture_8k_mercury", orbitalPeriodEarthYears: 0.2408467),
            BodyRecord(name: "Venus", path: "Sun", earthRadiusFraction: 0.3829, texturePath: "2k_venus_surface", orbitalPeriodEarthYears: 0.61519726),
            BodyRecord(name: "Earth", path: "Sun", earthRadiusFraction: 1, texturePath: "Solarsystemscope_texture_8k_earth_daymap", orbitalPeriodEarthYears: 1.0000174),
            BodyRecord(name: "Moon", path: "Earth", earthRadiusFraction: 0.2721, texturePath: "2k_moon", orbitalPeriodEarthYears: 1.0000174, bodyType: .NaturalSatellite),
            BodyRecord(name: "Mars", path: "Sun", earthRadiusFraction: 0.533, texturePath: "2k_mars", orbitalPeriodEarthYears: 1.8808476),
            BodyRecord(name: "Jupiter", path: "Sun", earthRadiusFraction: 11.21, texturePath: "2k_jupiter", orbitalPeriodEarthYears: 11.862615),
            BodyRecord(name: "Saturn", path: "Sun", earthRadiusFraction: 9.45, texturePath: "2k_saturn", orbitalPeriodEarthYears: 29.447498),
            BodyRecord(name: "Uranus", path: "Sun", earthRadiusFraction: 4.01, texturePath: "2k_uranus", orbitalPeriodEarthYears: 84.016846),
            BodyRecord(name: "Neptune", path: "Sun", earthRadiusFraction: 3.88, texturePath: "2k_neptune", orbitalPeriodEarthYears: 164.79132),
        ]
        
        return records
    }
}

//
//  PlanetSim.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/23/24.
//

import Foundation
import SceneKit

public class PlanetSim {
    private class EphemerisPlanet {
        public init(planet: novas_planet) {
            novas_object = object()
            make_planet(planet, &novas_object)
        }
        
        public func position(d: Date) -> SCNVector3 {
            let jd = d.julian2
            
            var jd_tdb: [Double] = [jd, 0.0]
            var eph_pos: [Double] = [0.0, 0.0, 0.0]
            var eph_vel: [Double] = [0.0, 0.0, 0.0]
            let retVal = ephemeris(&jd_tdb, &novas_object, NOVAS_HELIOCENTER,
                                   NOVAS_REDUCED_ACCURACY, &eph_pos, &eph_vel)
            
            return SCNVector3(x: eph_pos[0], y: eph_pos[1], z: eph_pos[2])
        }
        
        private var novas_object: object
    }
    
    static func mercuryPos(d: Date) -> SCNVector3 {
        return _mercury.position(d: d)
    }
    
    static func venusPos(d: Date) -> SCNVector3 {
        return _venus.position(d: d)
    }
    
    static func earthPos(d: Date) -> SCNVector3 {
        return _earth.position(d: d)
    }
    
    static func marsPos(d: Date) -> SCNVector3 {
        return _mars.position(d: d)
    }
    
    private static let _mercury = EphemerisPlanet(planet: NOVAS_MERCURY)
    private static let _venus = EphemerisPlanet(planet: NOVAS_VENUS)
    private static let _earth = EphemerisPlanet(planet: NOVAS_EARTH)
    private static let _mars = EphemerisPlanet(planet: NOVAS_MARS)
}

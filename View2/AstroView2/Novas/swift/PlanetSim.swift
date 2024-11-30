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
            let retVal = ephemeris(&jd_tdb, &novas_object, NOVAS_BARYCENTER,
                                   NOVAS_REDUCED_ACCURACY, &eph_pos, &eph_vel)
            
            return SCNVector3(x: eph_pos[0], y: eph_pos[1], z: eph_pos[2])
        }
        
        private var novas_object: object
    }
    
    private static func checkEphemeris() {
        _ephemeris
    }
    
    static func sunPos(d: Date) -> SCNVector3 {
        checkEphemeris()
        return _sun.position(d: d)
    }
    
    static func mercuryPos(d: Date) -> SCNVector3 {
        checkEphemeris()
        return _mercury.position(d: d)
    }
    
    static func venusPos(d: Date) -> SCNVector3 {
        checkEphemeris()
        return _venus.position(d: d)
    }
    
    static func earthPos(d: Date) -> SCNVector3 {
        checkEphemeris()
        let retVal = _earth.position(d: d)
        return retVal
    }
    
    static func moonPos(d: Date) -> SCNVector3 {
        checkEphemeris()
        return _moon.position(d: d)
    }
    
    static func marsPos(d: Date) -> SCNVector3 {
        checkEphemeris()
        return _mars.position(d: d)
    }
    
    private static let _sun = EphemerisPlanet(planet: NOVAS_SUN)
    private static let _mercury = EphemerisPlanet(planet: NOVAS_MERCURY)
    private static let _venus = EphemerisPlanet(planet: NOVAS_VENUS)
    private static let _earth = EphemerisPlanet(planet: NOVAS_EARTH)
    private static let _moon = EphemerisPlanet(planet: NOVAS_MOON)
    private static let _mars = EphemerisPlanet(planet: NOVAS_MARS)
    
    private static let _ephemeris = Ephemeris()
}

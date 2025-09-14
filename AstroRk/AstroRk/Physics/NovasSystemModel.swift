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
    private let _bodies: BodyCatalog
    
    public init() {
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: "lnxp1900p2053", ofType: "421", inDirectory: "ephemeris")!
        
        _planetSim = PlanetSim(ephemerisPath: resourcePath)
        
        _bodies = BodyCatalog()
    }
    
    public var bodyCatalog: BodyCatalog { _bodies }

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
}

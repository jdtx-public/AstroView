//
//  PlanetSim.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/23/24.
//

import Foundation
import SceneKit

public class PlanetSim {
    static func earthPos(d: Date) -> SCNVector3 {
        let jd = d.julian2
        
        var earth_pos: [Double] = [0.0, 0.0, 0.0]
        var earth_vel: [Double] = [0.0, 0.0, 0.0]
        let retVal = earth_sun_calc(jd, NOVAS_EARTH, NOVAS_HELIOCENTER, &earth_pos, &earth_vel)
        
        return SCNVector3(x: earth_pos[0], y: earth_pos[1], z: earth_pos[2])
    }
}

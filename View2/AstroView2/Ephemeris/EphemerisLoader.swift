//
//  EphemerisLoader.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/26/24.
//

import Foundation

public class EphemerisLoader {
    public static func load() {
        let mainBundle = Bundle.main
        let resourcePath = mainBundle.path(forResource: "lnxp1900p2053", ofType: "421", inDirectory: "ephemeris")!
        
        var cchars = resourcePath.utf8CString
        
        var jdBegin: Double = 0
        var jdEnd: Double = 0
        var jdNumber: Int16 = 0
        
        cchars.withUnsafeBufferPointer { buffer in
            ephem_open(buffer.baseAddress, &jdBegin, &jdEnd, &jdNumber)
        }
    }
    
    public static func unload() {
        ephem_close()
    }
}

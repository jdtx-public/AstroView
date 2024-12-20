//
//  AstroConstants.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/19/24.
//

import Foundation

public class AstroConstants {
    public static let earthRadius: Double = 1.0
    public static let earthMass: Double = 5.97219e24
    public static let oneAuInEarthRadii = 23454.8
    public static let oneAu: Double = oneAuInEarthRadii * earthRadius

    public static let oneAuInMiles = 92955807.267433
    public static let oneAuInKm = 149597870.691
    
    public static let oneEarthRadiusInKm = oneAuInKm / oneAuInEarthRadii
}

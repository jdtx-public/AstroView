//
//  BodyRecord.swift
//  AstroView2
//
//  Created by Jeff Doar on 12/16/24.
//

import Foundation

public enum BodyType {
    case Sun
    case Planet
    case NaturalSatellite
}

public class BodyRecord {
    public let name: String
    public let path: String
    public let earthRadiusFraction: Double
    public let texturePath: String
    public let orbitalPeriodEarthYears: Double
    public let bodyType: BodyType
    
    public init(name: String, path: String, earthRadiusFraction: Double, texturePath: String,
                orbitalPeriodEarthYears: Double, bodyType: BodyType = .Planet) {
        self.name = name
        self.path = path
        self.earthRadiusFraction = earthRadiusFraction
        self.texturePath = texturePath
        self.orbitalPeriodEarthYears = orbitalPeriodEarthYears
        self.bodyType = bodyType
    }
}

public extension BodyRecord {
    private static let _secondsInEarthYear : Double = 365.25 * 24 * 60 * 60

    func computeFractionalYearDate(from startDate: Date, withYearFraction: Double) -> Date {
        let fractionalYearDate = startDate.addingTimeInterval(BodyRecord._secondsInEarthYear * self.orbitalPeriodEarthYears * withYearFraction)
        return fractionalYearDate
    }
}

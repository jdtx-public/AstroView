//
//  DateExtensions.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/23/24.
//
import Foundation

public extension Date {
    var julian : Double {
        let jd = (self.timeIntervalSince1970 - 2440588.5) / 86400.0
        return jd
    }
    
    var julian2 : Double {
        let cal = Calendar(identifier: .gregorian)
        let dc = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        
        let jd2 = julian_date(Int16(dc.year!), Int16(dc.month!), Int16(dc.day!), Double(dc.hour!))
        
        return jd2
    }
}

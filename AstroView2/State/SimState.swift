//
//  SimState.swift
//  AstroView2
//
//  Created by Jeff Doar on 9/13/25.
//

import Foundation

class SimState {
    private var _curDate: Date
    
    public init() {
        _curDate = Date.now
    }
    
    public func advance(by: TimeInterval) {
        _curDate.addTimeInterval(by)
    }
    
    public func toNow() {
        _curDate = Date.now
    }
    
    public func toDate(_ date: Date) {
        _curDate = date
    }
}

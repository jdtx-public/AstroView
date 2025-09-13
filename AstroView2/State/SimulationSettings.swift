//
//  SimulationSettings.swift
//  AstroView2
//
//  Created by Jeff Doar on 9/13/25.
//

import Foundation

public class SimulationSettings {
    public var timeStepSeconds: Double {
        get {
            return _timeStepSeconds
        }
    }
    
    public func x2() {
        _timeStepSeconds *= 2.0
    }
    
    public func oneHalf() {
        _timeStepSeconds /= 2.0
    }
    
    public func stop() {
        _timeStepSeconds = 0.0
    }
    
    public func realTime() {
        _timeStepSeconds = 1.0
    }
    
    private var _timeStepSeconds: Double = 1.0
}

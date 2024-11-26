//
//  AppDelegate.swift
//  AstroView2
//
//  Created by Jeff Doar on 11/16/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ aNotification: Notification) {
        EphemerisLoader.load()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        EphemerisLoader.unload()
    }
}

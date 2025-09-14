//
//  AstroRkApp.swift
//  AstroRk
//
//  Created by Jeff Doar on 9/13/25.
//

import SwiftUI

@main
struct AstroRkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let systemModel: SystemModel = SpiceSystemModel()

    var body: some Scene {
        WindowGroup {
            ContentView(systemModel: systemModel)
        }
    }
}

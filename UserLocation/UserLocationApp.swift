//
//  UserLocationApp.swift
//  UserLocation
//
//  Created by Giventus Marco Victorio Handojo on 10/08/24.
//

import SwiftUI
import FirebaseCore

@main
struct UserLocationApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MapView()
        }
    }
}

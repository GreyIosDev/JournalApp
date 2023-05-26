//
//  JournalAppApp.swift
//  JournalApp
//
//  Created by Grey  on 24.05.2023.
//

import SwiftUI
import FirebaseCore

@main
struct JournalApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//
//  AiSpeechToTextV2App.swift
//  AiSpeechToTextV2
//
//  Created by Daniel Molina on 05/01/25.
//

import SwiftUI

@main
struct AiSpeechToTextV2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // Optional: hides the title bar
        .defaultSize(width: 400, height: 200) // Set default window size
        .windowResizability(.contentSize) // Prevent resizing
    }
}

//
//  AiSpeechToTextV2App.swift
//  AiSpeechToTextV2
//
//  Created by Daniel Molina on 05/01/25.
//

import SwiftUI

@main
struct AiSpeechToTextV2App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            // Prevent app from terminating when last window is closed
            CommandGroup(after: .appInfo) {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("q", modifiers: [.command])
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "Recording")

        // Create menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show", action: #selector(showApp), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu

        // Keep app running in background
        NSApp.setActivationPolicy(.accessory)
    }

    @objc func showApp() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // Show window if hidden
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showApp()
        return true
    }
}

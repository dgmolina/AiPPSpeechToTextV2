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
        Settings {
            EmptyView()
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
    var window: NSWindow?

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

        // Set initial activation policy
        NSApp.setActivationPolicy(.accessory)

        // Create and configure window if needed
        createWindowIfNeeded()
    }

    private func createWindowIfNeeded() {
        if window == nil {
            // Create a new window
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window?.center()
            window?.title = "AiSpeechToTextV2"
            window?.isReleasedWhenClosed = false

            // Set the PermissionsView as the window's content
            window?.contentView = NSHostingView(rootView: PermissionsView())
        }
    }

    @objc func showApp() {
        // Ensure window exists
        createWindowIfNeeded()

        // Show the app in dock
        NSApp.setActivationPolicy(.regular)

        // Bring window to front and make it key
        window?.makeKeyAndOrderFront(nil)
        window?.center()

        // Activate the app
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showApp()
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up when app terminates
        window = nil
    }
}

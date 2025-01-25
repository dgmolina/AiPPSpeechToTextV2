import Foundation
import Carbon
import AppKit

class KeyboardShortcutManager: ObservableObject {
    private var eventMonitor: Any?
    var onShortcutTriggered: (() -> Void)?

    init() {
        setupEventMonitor()
    }

    private func setupEventMonitor() {
        // Use global monitor to catch events even when app is in background
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            // Check for option + cmd + spacebar
            if event.modifierFlags.contains([.option, .command]) &&
               event.keyCode == kVK_Space {
                DispatchQueue.main.async {
                    self?.onShortcutTriggered?()
                }
            }
        }
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

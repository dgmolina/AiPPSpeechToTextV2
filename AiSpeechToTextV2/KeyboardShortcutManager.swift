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
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            if event.modifierFlags.contains(.option) &&
               event.keyCode == kVK_ANSI_R {
                self?.onShortcutTriggered?()
            }
            return event
        }
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

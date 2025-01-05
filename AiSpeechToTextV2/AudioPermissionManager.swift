import Foundation
import AppKit
import AVFoundation

class AudioPermissionManager: ObservableObject {
  @Published var permissionGranted: Bool = false

  init () {
    checkPermission()
  }

  func checkPermission() {
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
      case .authorized:
        permissionGranted = true
      case .notDetermined:
        requestPermission()
      case .denied, .restricted:
        permissionGranted = false
      @unknown default:
        permissionGranted = false
    }
  }

  func requestPermission() {
    AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
      guard let self = self else { return }
      self.permissionGranted = granted
    }
  }
    
    func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        }
    }
}

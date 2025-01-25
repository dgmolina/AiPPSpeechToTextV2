import SwiftUI
import AVFoundation
import AppKit
import Carbon

struct PermissionsView: View {
    @ObservedObject var audioPermissionManager = AudioPermissionManager()
    @State private var showingSettingsAlert = false
    @State private var permissionsGranted = false

    var body: some View {
        VStack {
            if permissionsGranted {
                ContentView()
            } else {
                VStack(spacing: 20) {
                    Text("Permissions Required")
                        .font(.title)
                        .padding(.bottom)

                    if !audioPermissionManager.permissionGranted {
                        VStack {
                            Text("Microphone Access:")
                                .font(.headline)
                            Text("AiSpeechToTextV2 needs microphone access to record audio for transcription.")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            if AVCaptureDevice.authorizationStatus(for: .audio) == .denied {
                                Button("Open System Settings") {
                                    showingSettingsAlert = true
                                }
                                .padding(.top)
                            } else if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
                                Button("Request Microphone Access") {
                                    audioPermissionManager.requestPermission()
                                }
                                .padding(.top)
                            } else {
                                Text("Microphone access granted.")
                                    .foregroundColor(.green)
                                    .padding(.top)
                            }
                        }
                        .padding()
                        .border(Color.gray)
                    }

                    VStack {
                        Text("Accessibility Access:")
                            .font(.headline)
                        Text("Accessibility permissions are needed for the keyboard shortcut to work globally.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Open System Settings") {
                            openAccessibilitySettings()
                        }
                        .padding(.top)
                    }
                    .padding()
                    .border(Color.gray)

                    if !audioPermissionManager.permissionGranted || !checkAccessibilityPermission() {
                        Text("Please grant the necessary permissions to use the app.")
                            .foregroundColor(.red)
                            .padding(.top)
                    }
                }
                .padding(50)
                .onAppear {
                    checkPermissionsStatus()
                    requestAccessibilityPermission()
                }
                .onChange(of: audioPermissionManager.permissionGranted) { _ in
                    checkPermissionsStatus()
                }
                .alert(isPresented: $showingSettingsAlert) {
                    Alert(
                        title: Text("Microphone Access Denied"),
                        message: Text("Please enable microphone access in System Settings to use this feature."),
                        primaryButton: .default(Text("Open Settings"), action: {
                            audioPermissionManager.openSystemSettings()
                        }),
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
            }
        }
    }

    private func checkPermissionsStatus() {
        permissionsGranted = audioPermissionManager.permissionGranted && checkAccessibilityPermission()
    }

    private func checkAccessibilityPermission() -> Bool {
        return AXIsProcessTrustedWithOptions(nil)
    }

    private func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func requestAccessibilityPermission() {
        print("requestAccessibilityPermission() called") // ADD THIS LINE
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if trusted {
            print("Accessibility permission granted")
            checkPermissionsStatus()
        } else {
            print("Accessibility permission not granted")
        }
    }
}

#Preview {
    PermissionsView()
}

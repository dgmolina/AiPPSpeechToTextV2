//
//  ContentView.swift
//  AiSpeechToTextV2
//
//  Created by Daniel Molina on 05/01/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var audioPermissionManager = AudioPermissionManager()
    @StateObject private var recordingManager = RecordingManager()
    @StateObject private var keyboardManager = KeyboardShortcutManager()

    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            // Recording Controls
            HStack(spacing: 20) {
                Button(action: recordingManager.toggleRecording) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 30))
                        .foregroundColor(audioPermissionManager.permissionGranted ? .primary : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!audioPermissionManager.permissionGranted)

                Circle()
                    .fill(recordingManager.isRecording ? Color.red : Color.gray)
                    .frame(width: 20, height: 20)
                    .opacity(recordingManager.isRecording ? 1 : 0.5)

                Text(String(format: "%.2fs", recordingManager.recordingTime))
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
            }
            .padding()

            // Transcription Status
            if recordingManager.isLoading {
                ProgressView("Transcribing...")
                    .padding()
            }

            if !recordingManager.transcription.isEmpty {
                ScrollView {
                    Text(recordingManager.transcription)
                        .padding()
                }
                .frame(maxHeight: 200)
            }

            if let error = recordingManager.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }

            // Update shortcut hint
            Text("Press ⌥R to start/stop recording")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .padding()
        .onReceive(timer) { _ in
            if recordingManager.isRecording {
                recordingManager.recordingTime += 0.01
            }
        }
        .onAppear {
            keyboardManager.onShortcutTriggered = {
                if audioPermissionManager.permissionGranted {
                    recordingManager.toggleRecording()
                }
            }
        }
        .alert("Microphone Access Required",
               isPresented: .constant(!audioPermissionManager.permissionGranted &&
                                     AVCaptureDevice.authorizationStatus(for: .audio) == .denied)) {
            Button("Open Settings") {
                audioPermissionManager.openSystemSettings()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable microphone access in System Settings to use this feature.")
        }
    }

}

#Preview {
    ContentView()
}

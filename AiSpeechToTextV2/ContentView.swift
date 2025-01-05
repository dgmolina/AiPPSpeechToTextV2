//
//  ContentView.swift
//  AiSpeechToTextV2
//
//  Created by Daniel Molina on 05/01/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var audioPermissionManager = AudioPermissionManager()
    @State private var isRecording = false
    @State private var recordingTime = 0.0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 20) {
            // Microphone Button
            Button(action: {
                if audioPermissionManager.permissionGranted {
                    isRecording.toggle()
                    recordingTime = 0
                } else {
                    audioPermissionManager.requestPermission()
                }
            }) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 30))
                    .foregroundColor(audioPermissionManager.permissionGranted ? .primary : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!audioPermissionManager.permissionGranted)

            // Recording Indicator
            Circle()
                .fill(isRecording ? Color.red : Color.gray)
                .frame(width: 20, height: 20)
                .opacity(isRecording ? 1 : 0.5)

            // Timer
            Text(String(format: "%.2fs", recordingTime))
                .font(.system(size: 20, weight: .medium, design: .monospaced))
                .onReceive(timer) { _ in
                    if isRecording {
                        recordingTime += 0.1
                    }
                }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.windowBackgroundColor))
                .shadow(radius: 5)
        )
        .padding()
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

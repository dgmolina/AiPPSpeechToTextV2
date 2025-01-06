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
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var transcriptionAgent: TranscriptionAgent = {
        guard let apiKey = ProcessInfo.processInfo.environment["AIPP_GEMINI_API_KEY"] else {
            fatalError("AIPP_GEMINI_API_KEY environment variable is not set.")
        }
        return TranscriptionAgent(apiKey: apiKey)
    }()
    @State private var recordingTime = 0.0
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            // Recording Controls
            HStack(spacing: 20) {
                Button(action: toggleRecording) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 30))
                        .foregroundColor(audioPermissionManager.permissionGranted ? .primary : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!audioPermissionManager.permissionGranted)
                
                Circle()
                    .fill(audioRecorder.isRecording ? Color.red : Color.gray)
                    .frame(width: 20, height: 20)
                    .opacity(audioRecorder.isRecording ? 1 : 0.5)
                
                Text(String(format: "%.2fs", recordingTime))
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
            }
            .padding()
            
            // Transcription Status
            if transcriptionAgent.isLoading {
                ProgressView("Transcribing...")
                    .padding()
            }
            
            if !transcriptionAgent.transcription.isEmpty {
                ScrollView {
                    Text(transcriptionAgent.transcription)
                        .padding()
                }
                .frame(maxHeight: 200)
            }
            
            if let error = transcriptionAgent.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .onReceive(timer) { _ in
            if audioRecorder.isRecording {
                recordingTime += 0.01
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
    
    private func toggleRecording() {
        if audioRecorder.isRecording {
            // Stop recording and start transcription
            audioRecorder.stopRecording { recordingURL in
                if let url = recordingURL {
                    Task {
                        do {
                            DispatchQueue.main.async {
                                transcriptionAgent.isLoading = true
                                transcriptionAgent.errorMessage = nil
                            }
                            
                            let transcription = try await transcriptionAgent.transcribeRecording(at: url)
                            
                            DispatchQueue.main.async {
                                transcriptionAgent.transcription = transcription
                                transcriptionAgent.isLoading = false
                            }
                        } catch {
                            DispatchQueue.main.async {
                                transcriptionAgent.errorMessage = error.localizedDescription
                                transcriptionAgent.isLoading = false
                            }
                        }
                    }
                }
            }
        } else {
            // Start new recording
            audioRecorder.startRecording()
            recordingTime = 0
            transcriptionAgent.transcription = ""
            transcriptionAgent.errorMessage = nil
        }
    }
}

#Preview {
    ContentView()
}

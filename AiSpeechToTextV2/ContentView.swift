//
//  ContentView.swift
//  AiSpeechToTextV2
//
//  Created by Daniel Molina on 05/01/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    @State private var recordingTime = 0.0
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 20) {
            // Microphone Button
            Button(action: {
                isRecording.toggle()
                recordingTime = 0
            }) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.primary)
            }
            .buttonStyle(PlainButtonStyle())
            
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
                        recordingTime += 0.01
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
    }
}

#Preview {
    ContentView()
}

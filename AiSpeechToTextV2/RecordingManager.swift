import Foundation
import AVFoundation

class RecordingManager: ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime = 0.0
    @Published var transcription: String = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let audioRecorder = AudioRecorder()
    private let transcriptionAgent: TranscriptionAgent
    
    init() {
        guard let apiKey = ProcessInfo.processInfo.environment["AIPP_GEMINI_API_KEY"] else {
            fatalError("AIPP_GEMINI_API_KEY environment variable is not set.")
        }
        self.transcriptionAgent = TranscriptionAgent(apiKey: apiKey)
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        audioRecorder.startRecording()
        isRecording = true
        recordingTime = 0
        transcription = ""
        errorMessage = nil
    }
    
    private func stopRecording() {
        audioRecorder.stopRecording { recordingURL in
            if let url = recordingURL {
                Task {
                    do {
                        DispatchQueue.main.async {
                            self.isLoading = true
                            self.errorMessage = nil
                        }
                        
                        let transcription = try await self.transcriptionAgent.transcribeRecording(at: url)
                        
                        DispatchQueue.main.async {
                            self.transcription = transcription
                            self.isLoading = false
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.errorMessage = error.localizedDescription
                            self.isLoading = false
                        }
                    }
                }
            }
        }
        isRecording = false
    }
}

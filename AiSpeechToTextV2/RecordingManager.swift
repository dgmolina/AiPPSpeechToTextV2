import Foundation
import AVFoundation
import os.log

class RecordingManager: ObservableObject {
    private let logger = Logger(subsystem: "com.yourapp.AiSpeechToTextV2", category: "RecordingManager")
    
    @Published var isRecording = false
    @Published var recordingTime = 0.0
    @Published var transcription: String = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let audioRecorder = AudioRecorder()
    private let transcriptionAgent: TranscriptionAgent
    
    init() {
        guard let apiKey = ProcessInfo.processInfo.environment["AIPP_GEMINI_API_KEY"] else {
            logger.error("AIPP_GEMINI_API_KEY environment variable is not set.")
            fatalError("AIPP_GEMINI_API_KEY environment variable is not set.")
        }
        logger.info("RecordingManager initialized with API key: \(apiKey.prefix(4))...") // Log first 4 chars for debugging
        self.transcriptionAgent = TranscriptionAgent(apiKey: apiKey)
    }
    
    func toggleRecording() {
        if isRecording {
            logger.info("Stopping recording...")
            stopRecording()
        } else {
            logger.info("Starting recording...")
            startRecording()
        }
    }
    
    private func startRecording() {
        audioRecorder.startRecording()
        isRecording = true
        recordingTime = 0
        transcription = ""
        errorMessage = nil
        logger.info("Recording started.")
    }
    
    private func stopRecording() {
        audioRecorder.stopRecording { recordingURL in
            if let url = recordingURL {
                self.logger.info("Recording stopped. Waiting 2 seconds before starting transcription...")
                
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
                                self.logger.info("Transcription completed successfully.")
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.errorMessage = error.localizedDescription
                                self.isLoading = false
                                self.logger.error("Transcription failed: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            } else {
                self.logger.error("No recording URL found after stopping recording.")
            }
        }
        isRecording = false
    }
}

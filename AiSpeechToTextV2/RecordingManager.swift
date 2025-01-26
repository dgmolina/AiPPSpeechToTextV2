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
    private var _transcriptionAgent: TranscriptionAgent? // Make it optional and private
    var transcriptionAgent: TranscriptionAgent { // Computed property to safely access it
        return _transcriptionAgent ?? TranscriptionAgent(apiKey: "") // Return default if not initialized
    }
    private let soundEffectPlayer = SoundEffectPlayer()

    init() {
        guard let apiKey = ProcessInfo.processInfo.environment["AIPP_GEMINI_API_KEY"], !apiKey.isEmpty else {
            self.errorMessage = "API key not set. Please set the AIPP_GEMINI_API_KEY environment variable."
            self.isLoading = false // Ensure isLoading is false in error case
            return // Early return to prevent further initialization with invalid key
        }
        logger.info("RecordingManager initialized with API key: \(apiKey.prefix(4))...")
        _transcriptionAgent = TranscriptionAgent(apiKey: apiKey) // Initialize if API key is valid
    }

    func toggleRecording(isTranslationEnabled: Bool = false) {
        if isRecording {
            logger.info("Stopping recording...")
            stopRecording(isTranslationEnabled: isTranslationEnabled)
        } else {
            logger.info("Starting recording...")
            startRecording()
        }
    }

    private func startRecording() {
        soundEffectPlayer.playStartSound()
        audioRecorder.startRecording()
        isRecording = true
        recordingTime = 0
        transcription = ""
        errorMessage = nil
        logger.info("Recording started.")
    }

    private func stopRecording(isTranslationEnabled: Bool = false) {
        audioRecorder.stopRecording { recordingURL in
            if let url = recordingURL {
                self.logger.info("Recording stopped. Starting transcription...")

                Task {
                    do {
                        DispatchQueue.main.async {
                            self.isLoading = true
                            self.errorMessage = nil
                        }

                        let transcription = try await self.transcriptionAgent.transcribeRecording(at: url, isTranslationEnabled: isTranslationEnabled)

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
            } else {
                self.logger.error("No recording URL found after stopping recording.")
            }
        }
        isRecording = false
    }
}

//
//  TranscriptionAgent.swift
//  AiSpeechToTextV2
//
//  Created by Daniel Molina on 05/01/25.
//

import Foundation
import GoogleGenerativeAI

class TranscriptionAgent: ObservableObject {
    private var model: GenerativeModel?
    @Published var isLoading = false
    @Published var transcription: String = ""
    @Published var errorMessage: String?
    
    init(apiKey: String) {
        self.model = GenerativeModel(name: "gemini-2.0-flash-exp", apiKey: apiKey)
    }
    
    func transcribeRecording(at url: URL) async throws -> String {
        guard let model = model else {
            throw NSError(domain: "TranscriptionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model not initialized"])
        }
        
        let audioData = try Data(contentsOf: url)
        let mimeType = getMIMEType(from: url)
        
        let audioPart = ModelContent.Part.data(mimeType, audioData)
        let promptPart = ModelContent.Part.text("Transcribe this audio")
        
        let response = try await model.generateContent(promptPart, audioPart)
        return response.text ?? "No transcription available"
    }
    
    private func getMIMEType(from url: URL) -> String {
        let fileExtension = url.pathExtension
        switch fileExtension {
        case "wav": return "audio/wav"
        case "mp3": return "audio/mp3"
        case "m4a": return "audio/mp4"
        default: return "audio/mpeg"
        }
    }
    
}

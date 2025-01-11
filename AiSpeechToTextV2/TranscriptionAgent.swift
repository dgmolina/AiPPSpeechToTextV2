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
        guard !apiKey.isEmpty else {
            fatalError("API key cannot be empty.")
        }
        self.model = GenerativeModel(name: "gemini-2.0-flash-exp", apiKey: apiKey)
    }

    func transcribeRecording(at url: URL) async throws -> String {
        guard let model = model else {
            throw NSError(domain: "TranscriptionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model not initialized"])
        }

        print("Starting transcription for file at: \(url.path)")

        let audioData = try Data(contentsOf: url)
        let mimeType = getMIMEType(from: url)

        print("Audio data loaded. Size: \(audioData.count) bytes")
        print("MIME type: \(mimeType)")

        let audioPart = ModelContent.Part.data(mimetype: mimeType, audioData)
        let promptPart = ModelContent.Part.text("""
        Transcribe this audio and clean up the transcription by:
        1. Remove self-corrections (e.g., "I went to the park. I mean. The beach" should become "I went to the beach")
        2. Remove filler words and pauses (e.g., "uh", "ah", "like")
        3. Create clear, continuous sentences

        Examples of corrections:
        - "I went to the park. I mean. The beach" → "I went to the beach"
        - "The presentation is. Uh. Like. Tomorrow" → "The presentation is tomorrow"
        - "Eu fui no mercado. Quero dizer. No shopping" → "Eu fui no shopping"
        - "A reunião será. Ah. Em. Amanhã" → "A reunião será amanhã"

        Please provide a clean, polished transcription.
        """)

        print("Sending request to Gemini API...")

        do {
            let response = try await model.generateContent(promptPart, audioPart)
            print("Received response from Gemini API")
            return response.text ?? "No transcription available"
        } catch {
            print("API request failed: \(error)")
            throw error
        }
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

//
//  TranscriptionAgent.swift
//  AiSpeechToTextV2
//
//  Created by Daniel Molina on 05/01/25.
//

import Foundation
import GoogleGenerativeAI
import AppKit

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
            let transcription = response.text ?? "No transcription available"
            copyToClipboard(transcription) // Add this line
            return transcription
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

extension TranscriptionAgent {
    func copyToClipboard(_ text: String) {
        // First copy to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Then simulate CMD+V to paste in current focus
        DispatchQueue.main.async {
            let source = CGEventSource(stateID: .privateState)

            // Create CMD down event
            let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
            // Create V down event
            let vDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
            // Create V up event
            let vUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
            // Create CMD up event
            let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

            // Set CMD flag
            vDown?.flags = .maskCommand
            vUp?.flags = .maskCommand

            // Post events
            cmdDown?.post(tap: .cghidEventTap)
            vDown?.post(tap: .cghidEventTap)
            vUp?.post(tap: .cghidEventTap)
            cmdUp?.post(tap: .cghidEventTap)
        }
    }
}

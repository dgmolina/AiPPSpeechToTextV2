//
//  AudioRecorder.swift
//  AiSpeechToTextV2
//
//  Created by Daniel Molina on 05/01/25.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
    private var captureSession: AVCaptureSession?
    private var audioFileOutput: AVCaptureAudioFileOutput?
    @Published var isRecording = false

    override init() {
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("No audio device found")
            return
        }

        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)

            if captureSession?.canAddInput(audioInput) == true {
                captureSession?.addInput(audioInput)
            }

            audioFileOutput = AVCaptureAudioFileOutput()

            if let audioFileOutput = audioFileOutput,
               captureSession?.canAddOutput(audioFileOutput) == true {
                captureSession?.addOutput(audioFileOutput)
            }

            captureSession?.startRunning()
        } catch {
            print("Error setting up audio capture: \(error.localizedDescription)")
        }
    }

    func startRecording() {
        guard let captureSession = captureSession, captureSession.isRunning else {
            print("Capture session not ready")
            return
        }

        let outputFileURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        do {
            try FileManager.default.removeItem(at: outputFileURL)
        } catch {
            // File doesn't exist, that's fine
        }

        audioFileOutput?.startRecording(to: outputFileURL, outputFileType: .m4a, recordingDelegate: self)
        isRecording = true
    }

    func stopRecording() {
        audioFileOutput?.stopRecording()
        isRecording = false
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension AudioRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        print("Started recording to: \(fileURL)")
    }

    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        } else {
            print("Recording finished successfully: \(outputFileURL)")
        }
    }
}

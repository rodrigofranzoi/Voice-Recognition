//
//  SpeechRecognizerProvider.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 15/08/2023.
//

import Foundation
import Speech
import Combine

protocol SpeechRecognizerProviderType {
    var valueReceived: AnyPublisher<String, SpeechRecognizerError> { get }
    
    func start() -> AnyPublisher<Void, SpeechRecognizerError>
    func stop()
}

enum SpeechRecognizerError: Error {
    case startFailure
    case notStarted
    case localeNotAvailable
    case otherError(_ error: Error)
}

class SpeechRecognizerProvider: NSObject, SpeechRecognizerProviderType, SFSpeechRecognizerDelegate {
    public let locale: Locale
    
    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognitionSubject = PassthroughSubject<String, SpeechRecognizerError>()
    
    init(locale: Locale = .init(identifier: "en_US")) {
        self.locale = locale
    }

    public func start() -> AnyPublisher<Void, SpeechRecognizerError> {
        let audioEngine = AVAudioEngine()
        self.audioEngine = audioEngine
        self.request = SFSpeechAudioBufferRecognitionRequest()
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return Fail(error: SpeechRecognizerError.startFailure).eraseToAnyPublisher()
        }
        return Empty().eraseToAnyPublisher()
    }
    
    public var valueReceived: AnyPublisher<String, SpeechRecognizerError> {
        if task == nil {
            guard let recognizer = self.speechRecognizer,
                  let request = self.request,
                  recognizer.isAvailable else {
                recognitionSubject.send(completion: .failure(.notStarted))
                return recognitionSubject
                    .eraseToAnyPublisher()
            }
            self.task = recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    self.recognitionSubject.send(completion: .failure(.otherError(error)))
                }
                guard let result = result else { return }
                if let lastSegment = result.bestTranscription.segments.last {
                    let lastWord = lastSegment.substring
                    self.recognitionSubject.send(lastWord)
                }
            }
        }
        return recognitionSubject
            .share()
            .eraseToAnyPublisher()
    }
    
    public func stop() {
        task?.finish()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
}

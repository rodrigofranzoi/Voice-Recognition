//
//  SpeechRecognizerProviderMock.swift
//  Zupan-VoiceRecognitionTests
//
//  Created by Rodrigo Scroferneker on 18/08/2023.
//

import Foundation
import Combine
@testable import Zupan_VoiceRecognition

final class SpeechRecognizerProviderMock: SpeechRecognizerProviderType {
    let mockSequence: [String]
    private let recognitionSubject = PassthroughSubject<String, SpeechRecognizerError>()

    init(mockSequence: [String]) {
        self.mockSequence = mockSequence
    }

    var valueReceived: PassthroughSubject<String, Zupan_VoiceRecognition.SpeechRecognizerError> {
        self.mockSequence.forEach { command in self.recognitionSubject.send(command) }
        return recognitionSubject
    }

    func start() -> AnyPublisher<(), Zupan_VoiceRecognition.SpeechRecognizerError> {
        return Just(())
            .setFailureType(to: SpeechRecognizerError.self)
            .eraseToAnyPublisher()
    }

    func stop() { }
}

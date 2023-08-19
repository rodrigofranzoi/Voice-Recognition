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

    var valueReceived: AnyPublisher<String, Zupan_VoiceRecognition.SpeechRecognizerError> {
        self.mockSequence.forEach { command in self.recognitionSubject.send(command) }
        return recognitionSubject.eraseToAnyPublisher()
    }

    func start() -> AnyPublisher<Void, Zupan_VoiceRecognition.SpeechRecognizerError> {
        return Empty().eraseToAnyPublisher()
    }

    func stop() { }
}

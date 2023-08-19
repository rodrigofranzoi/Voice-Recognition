//
//  MicrophonePermissionManager.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 17/08/2023.
//

import Foundation
import Combine
import Speech

protocol SpeechPermissionUseCaseType {
    var isGranted: Bool { get }
    var notDetermined: Bool { get }
    var status: SFSpeechRecognizerAuthorizationStatus { get }

    func requestAuthorization(_ completion: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void)
}

final class SpeechPermissionUseCase: SpeechPermissionUseCaseType {
    var isGranted: Bool { SFSpeechRecognizer.authorizationStatus() == .authorized }
    var notDetermined: Bool { SFSpeechRecognizer.authorizationStatus() == .notDetermined }
    var status: SFSpeechRecognizerAuthorizationStatus { SFSpeechRecognizer.authorizationStatus() }

    func requestAuthorization(_ completion: @escaping (SFSpeechRecognizerAuthorizationStatus) -> Void) {
        SFSpeechRecognizer.requestAuthorization(completion)
    }
}

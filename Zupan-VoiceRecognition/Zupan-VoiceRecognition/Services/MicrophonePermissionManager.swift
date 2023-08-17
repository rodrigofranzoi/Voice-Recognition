//
//  MicrophonePermissionManager.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 17/08/2023.
//

import Foundation
import Combine

enum MicrophonePermissionState {
    case ganted
    case denied
    case unknown
}

protocol MicrophonePermissionManagerType {
    var isGranted: Bool { get }
    var state: MicrophonePermissionState { get }
    
    func hasChanged() -> AnyPublisher<MicrophonePermissionState, Never>
}

class MicrophonePermissionManager: MicrophonePermissionManagerType {
    var isGranted: Bool { false }
    
    var state: MicrophonePermissionState { .denied }
    
    func hasChanged() -> AnyPublisher<MicrophonePermissionState, Never> {
        Just(.denied).eraseToAnyPublisher()
    }
}

//
//  MicrophonePermissionUseCase.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 17/08/2023.
//

import Foundation
import AVFAudio

protocol MicrophonePermissionUseCaseType {
    var isGranted: Bool { get }
    var notDetermined: Bool { get }
    var status: AVAudioSession.RecordPermission { get }

    func requestAuthorization(_ completion: @escaping (Bool) -> Void)
}

final class MicrophonePermissionUseCase: MicrophonePermissionUseCaseType {
    var isGranted: Bool { AVAudioSession.sharedInstance().recordPermission == .granted }
    var notDetermined: Bool { AVAudioSession.sharedInstance().recordPermission == .undetermined }
    var status: AVAudioSession.RecordPermission { AVAudioSession.sharedInstance().recordPermission }

    func requestAuthorization(_ completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission(completion)
    }
}

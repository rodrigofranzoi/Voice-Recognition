//
//  SpeechToCommandHistory.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 16/08/2023.
//

import Foundation

struct SpeechToCommandInput: Codable, Equatable {
    let command: String
    let value: String
}

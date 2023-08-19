//
//  Translations.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 17/08/2023.
//

import Foundation

struct Translations {
    static let startButton = String(localized: "start_speech")
    static let stopButton = String(localized: "stop_speech")
    static let empty = String(localized: "empty")
    static let noSpeechPermissionTitle = String(localized: "noSpeechPermissionTitle")
    static let noSpeechPermissionBody = String(localized: "noSpeechPermissionBody")
    static let askSpeechPermissionTitle = String(localized: "askSpeechPermissionTitle")
    static let askSpeechPermissionBody = String(localized: "askSpeechPermissionBody")
    static let noMicPermissionTitle = String(localized: "noMicPermissionTitle")
    static let noMicPermissionBody = String(localized: "noMicPermissionBody")
    static let askMicPermissionTitle = String(localized: "askMicPermissionTitle")
    static let askMicPermissionBody = String(localized: "askMicPermissionBody")
    static let openSettings = String(localized: "openSettings")
    static let cancel = String(localized: "cancel")
    static let continueString = String(localized: "continue")
    static let commands = String(localized: "commands")
    static let history = String(localized: "history")
    static let noHistory = String(localized: "noHistory")
    static let dismiss = String(localized: "dismiss")
    static let rulesTitle = String(localized: "rulesTitle")
    static let rulesDescription = String(localized: "rulesDescription")
}

typealias Tr = Translations

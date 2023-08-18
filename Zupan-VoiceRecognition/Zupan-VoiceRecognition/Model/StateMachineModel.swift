//
//  StateMachineNode.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 17/08/2023.
//

import Foundation

struct StateMachineDescription: Codable {
    let version: String
    let language: String
    let acceptedCommands: Set<String>
    let acceptedWords: Set<String>
    let replacableWords: [String: String]
    let commands: [StateMachineNode]
}

struct StateMachineNode: Codable {
    let command: String
    let nextCommands: Set<String>
    let acceptedParameters: Set<String>?
    let action: StateMachineAction
}

enum StateMachineAction: String, Codable {
    case store = "store"
    case remove = "remove"
    case cancel = "cancel"
}

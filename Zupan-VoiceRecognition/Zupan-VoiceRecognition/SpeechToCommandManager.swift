//
//  SpeechToCommandManager.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 16/08/2023.
//

import Foundation
import Combine

protocol SpeechToCommandManagerType {
    func start()
    func reset()
    func stop()
    
    func handleActionFor(state: SpeechToCommandState, command: String) -> String
    
    var stateProvider: AnyPublisher<SpeechToCommandState, Never> { get }
    var historyValueProvider: AnyPublisher<[SpeechToCommandHistory], Never> { get }
    var bufferProvider: AnyPublisher<String, Never> { get }
    var lastCommandProvider: AnyPublisher<String, Never> { get }
}

enum SpeechToCommandState: String {
    case count = "count"
    case reset = "reset"
    case code = "code"
    case back = "back"
    case idle = "idle"
    
    var acceptedParameters: Set<String> {
        switch self {
        case .count, .code:
            return ["one", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        case .reset, .back, .idle:
            return []
        }
    }
    
    var acceptedCommands: Set<String> {
        switch self {
        case .count, .code, .reset, .back, .idle:
            return ["count", "code", "reset", "back"]
        }
    }
}

class SpeechToCommandManager: SpeechToCommandManagerType {
    private let manager: SpeechRecognizerProviderType
    private let availableCommands: Set<String>
    private var cancellables = Set<AnyCancellable>()
    
    @Published var state: SpeechToCommandState = .idle
    @Published var history: [SpeechToCommandHistory] = []
    @Published var lastCommand: String = ""
    @Published var buff: String = ""
    
    init(
        manager: SpeechRecognizerProviderType,
        availableCommands: Set<String>
    ) {
        self.manager = manager
        self.availableCommands = availableCommands
    }
    
    public func start() {
        let _ = manager.start()
        
        self.speechValueProvider
            .sink()
            .store(in: &cancellables)
    }
    
    public func stop() {
        manager.stop()
        cancellables.forEach { $0.cancel() }
        state = .idle
    }
    
    public func reset() {
        self.stop()
        history.removeAll()
    }
    
    public var stateProvider: AnyPublisher<SpeechToCommandState, Never> {
        $state
            .removeDuplicates(by: { $0 == $1 && !self.buff.isEmpty })
            .filter { $0 != .idle }
            .eraseToAnyPublisher()

    }
    
    public var historyValueProvider: AnyPublisher<[SpeechToCommandHistory], Never> {
        $history
            .removeDuplicates(by: { $0.count == $1.count })
            .eraseToAnyPublisher()
    }
    
    public var bufferProvider: AnyPublisher<String, Never> {
        $buff
            .eraseToAnyPublisher()
    }
    
    public var lastCommandProvider: AnyPublisher<String, Never> {
        $lastCommand
            .eraseToAnyPublisher()
    }
    

    private var speechValueProvider: AnyPublisher<String, SpeechRecognizerError> {
        manager
            .valueReceived
            .map { $0.lowercased() }
            .filter { self.availableCommands.contains($0) }
            .map { $0 == "one" ? "1" : $0 }
            .map { command in self.handleActionFor(state: self.state, command: command) }
            .eraseToAnyPublisher()
    }
    
    public func handleActionFor(state: SpeechToCommandState, command: String) -> String {
        if self.state.acceptedParameters.contains(command) {
            self.buff += command
        } else if self.state.acceptedCommands.contains(command) {
            let newState = SpeechToCommandState(rawValue: command) ?? .idle
            self.lastCommand = newState.rawValue
            switch newState {
            case .count, .code:
                if state != .idle && !buff.isEmpty {
                    let newCommand = SpeechToCommandHistory(value: self.state.rawValue, parameter: self.buff)
                    self.history.append(newCommand)
                }
                self.buff = ""
                self.state = newState
            case .back, .reset:
                if !history.isEmpty { history.removeLast() }
                self.state = .idle
            default: break
            }
        }
        return command
    }
}

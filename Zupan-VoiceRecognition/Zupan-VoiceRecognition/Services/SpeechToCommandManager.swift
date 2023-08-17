//
//  SpeechToCommandManager.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 16/08/2023.
//

import Foundation
import Combine

protocol SpeechToCommandManagerType {
    var stateProvider: AnyPublisher<StateMachineNode, Never> { get }
    var historyValueProvider: AnyPublisher<[SpeechToCommandInput], Never> { get }
    var bufferProvider: AnyPublisher<String, Never> { get }
    var lastCommandProvider: AnyPublisher<String, Never> { get }
    
    func start()
    func reset()
    func stop()
    func handleActionFor(_ value: String) -> String?
}

class SpeechToCommandManager: SpeechToCommandManagerType {

    private let manager: SpeechRecognizerProviderType
    private let stateMachine: StateMachineDescription
    private var cancellables = Set<AnyCancellable>()
    
    @Published var state: StateMachineNode?
    @Published var history: [SpeechToCommandInput] = []
    @Published var lastCommand: String?
    @Published var buff: String = ""
    
    init(
        manager: SpeechRecognizerProviderType,
        stateMachine: StateMachineDescription
    ) {
        self.manager = manager
        self.stateMachine = stateMachine
    }
    
    public func start() {
        let _ = manager.start()
        
        self.speechValueProvider
            .sink()
            .store(in: &cancellables)
    }
    
    public func stop() {
        if let actualState = self.state,
           actualState.action == .store,
           !buff.isEmpty {
            let newCommand = SpeechToCommandInput(command: actualState.command, value: self.buff)
            self.history.append(newCommand)
        }
        manager.stop()
        cancellables.forEach { $0.cancel() }
        state = nil
        buff.removeAll()
    }
    
    public func reset() {
        self.stop()
        history.removeAll()
    }
    
    public var stateProvider: AnyPublisher<StateMachineNode, Never> {
        $state
            .compactMap { $0 }
            .removeDuplicates(by: { $0.command == $1.command && self.buff.isEmpty })
            .eraseToAnyPublisher()
    }

    public var historyValueProvider: AnyPublisher<[SpeechToCommandInput], Never> {
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
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    

    private var speechValueProvider: AnyPublisher<String, SpeechRecognizerError> {
        manager
            .valueReceived
            .map { $0.lowercased() }
            .filter { self.stateMachine.acceptedWords.contains($0) }
            .map { self.stateMachine.replacableWords[$0] ?? $0 }
            .compactMap { value in self.handleActionFor(value) }
            .share()
            .eraseToAnyPublisher()
    }
    
    public func handleActionFor(_ value: String) -> String? {
        guard let actualState = self.state else {
            self.state = self.stateMachine.commands.first(where: { $0.command == value })
            if state != nil {
                self.lastCommand = value
                return value
            }
            return nil
        }
        
        if let parameters = actualState.acceptedParameters,
               parameters.contains(value) {
            self.buff += value
        } else if actualState.nextCommands.contains(value),
               let newState = self.stateMachine.commands.first(where: { $0.command == value }) {
            switch (actualState.action, newState.action) {
            case (_, .store) :
                if !buff.isEmpty {
                    let newCommand = SpeechToCommandInput(command: actualState.command, value: self.buff)
                    self.history.append(newCommand)
                }
                self.buff.removeAll()
            case (.remove, .remove):
                if !history.isEmpty { history.removeLast() }
            default: break
            }
            
            self.lastCommand = value
            self.state = newState
            self.buff.removeAll()
        }
        return value
    }
}

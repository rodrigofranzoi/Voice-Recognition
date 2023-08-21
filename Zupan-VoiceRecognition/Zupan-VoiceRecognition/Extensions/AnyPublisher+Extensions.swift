//
//  AnyPublisher+Extensions.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 16/08/2023.
//

import Foundation
import Combine

extension Publisher {
    @discardableResult func sink() -> AnyCancellable {
        self.sink { _ in } receiveValue: { _ in }
    }

    @discardableResult func sink(receiveValue: @escaping ((Output) -> Void)) -> AnyCancellable {
        self.sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
    }
}

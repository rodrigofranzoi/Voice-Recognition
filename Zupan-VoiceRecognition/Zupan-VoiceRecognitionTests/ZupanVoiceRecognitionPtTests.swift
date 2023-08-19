//
//  ZupanVoiceRecognitionPtTests.swift
//  Zupan-VoiceRecognitionTests
//
//  Created by Rodrigo Scroferneker on 19/08/2023.
//

import XCTest
import Combine
@testable import Zupan_VoiceRecognition

final class ZupanVoiceRecognitionPtTests: XCTestCase {
    let stateMachineFilename: String = "stateMachineDescription-pt"
    var stateMachineDescription: StateMachineDescription!
    var sut: SpeechToCommandManagerType!

    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        guard let path = Bundle.main.path(forResource: stateMachineFilename, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let stateMachineDescription = try? JSONDecoder().decode(StateMachineDescription.self, from: data) else {
            fatalError("Language not available")
        }

        self.stateMachineDescription = stateMachineDescription
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOneCommand_expectOneSaved() throws {
        // Given
        let mockSequence = ["contar", "1", "2", "3"]
        let manager = SpeechRecognizerProviderMock(mockSequence: mockSequence)
        let sut: SpeechToCommandManagerType = SpeechToCommandManager(
            manager: manager,
            stateMachine: self.stateMachineDescription
        )

        // When
        sut.start()
        manager
            .valueReceived
            .sink()
            .store(in: &cancellables)
        sut.stop()

        // Then
        XCTAssertEqual(sut.history.count, 1)
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "contar", value: "123"))
    }

    func testBackCommand() throws {
        // Given
        let mockSequence = ["contar", "1", "2", "3", "código", "3", "contar", "3", "voltar"]
        let manager = SpeechRecognizerProviderMock(mockSequence: mockSequence)
        let sut: SpeechToCommandManagerType = SpeechToCommandManager(
            manager: manager,
            stateMachine: self.stateMachineDescription
        )

        // When
        sut.start()
        manager
            .valueReceived
            .sink()
            .store(in: &cancellables)
        sut.stop()

        // Then
        XCTAssertEqual(sut.history.count, 1)
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "contar", value: "123"))
    }

    func testResetCommand() throws {
        // Given
        let mockSequence = ["contar", "1", "2", "3", "código", "3", "contar", "3", "resetar"]
        let manager = SpeechRecognizerProviderMock(mockSequence: mockSequence)
        let sut: SpeechToCommandManagerType = SpeechToCommandManager(
            manager: manager,
            stateMachine: self.stateMachineDescription
        )

        // When
        sut.start()
        manager
            .valueReceived
            .sink()
            .store(in: &cancellables)
        sut.stop()
        // Then
        XCTAssertEqual(sut.history.count, 2)
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "contar", value: "123"))
        XCTAssertEqual(sut.history[1], SpeechToCommandInput(command: "código", value: "3"))
    }

    func testOneCommandCamelCased_expectOneSaved() throws {
        // Given
        let mockSequence = ["contar", "1", "2", "3"]
        let manager = SpeechRecognizerProviderMock(mockSequence: mockSequence)
        let sut: SpeechToCommandManagerType = SpeechToCommandManager(
            manager: manager,
            stateMachine: self.stateMachineDescription
        )

        // When
        sut.start()
        manager
            .valueReceived
            .sink()
            .store(in: &cancellables)
        sut.stop()

        // Then
        XCTAssertEqual(sut.history.count, 1)
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "contar", value: "123"))
    }

    func testTwoCommand_expectOneSaved() throws {
        // Given
        let mockSequence = ["contar", "1", "2", "3", "contar"]
        let manager = SpeechRecognizerProviderMock(mockSequence: mockSequence)
        let sut: SpeechToCommandManagerType = SpeechToCommandManager(
            manager: manager,
            stateMachine: self.stateMachineDescription
        )

        // When
        sut.start()
        manager
            .valueReceived
            .sink()
            .store(in: &cancellables)
        sut.stop()

        // Then
        XCTAssertEqual(sut.history.count, 1)
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "contar", value: "123"))
    }

    func testTwoCommandCount_expectOneTwoSaved() throws {
        // Given
        let mockSequence = ["contar", "1", "2", "3", "contar", "1"]
        let manager = SpeechRecognizerProviderMock(mockSequence: mockSequence)
        let sut: SpeechToCommandManagerType = SpeechToCommandManager(
            manager: manager,
            stateMachine: self.stateMachineDescription
        )

        // When
        sut.start()
        manager
            .valueReceived
            .sink()
            .store(in: &cancellables)
        sut.stop()

        // Then
        XCTAssertEqual(sut.history.count, 2)
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "contar", value: "123"))
        XCTAssertEqual(sut.history[1], SpeechToCommandInput(command: "contar", value: "1"))
    }

    func testTwoCommandCode_expectOneTwoSaved() throws {
        // Given
        let mockSequence = ["código", "1", "2", "3", "código", "1"]
        let manager = SpeechRecognizerProviderMock(mockSequence: mockSequence)
        let sut: SpeechToCommandManagerType = SpeechToCommandManager(
            manager: manager,
            stateMachine: self.stateMachineDescription
        )

        // When
        sut.start()
        manager
            .valueReceived
            .sink()
            .store(in: &cancellables)
        sut.stop()

        // Then
        XCTAssertEqual(sut.history.count, 2)
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "código", value: "123"))
        XCTAssertEqual(sut.history[1], SpeechToCommandInput(command: "código", value: "1"))
    }

    func testOneCommand_withOneAsParameter_expectOneCommandSaved() throws {
        // Given
        let mockSequence = ["contar", "um", "2", "3"]
        let manager = SpeechRecognizerProviderMock(mockSequence: mockSequence)
        let sut: SpeechToCommandManagerType = SpeechToCommandManager(
            manager: manager,
            stateMachine: self.stateMachineDescription
        )

        // When
        sut.start()
        manager
            .valueReceived
            .sink()
            .store(in: &cancellables)
        sut.stop()

        // Then
        XCTAssertEqual(sut.history.count, 1)
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "contar", value: "123"))
    }
}

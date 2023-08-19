//
//  ZupanVoiceRecognitionDeTests.swift
//  Zupan-VoiceRecognitionTests
//
//  Created by Rodrigo Scroferneker on 19/08/2023.
//

import XCTest
import Combine
@testable import Zupan_VoiceRecognition

final class ZupanVoiceRecognitionDeTests: XCTestCase {
    let stateMachineFilename: String = "stateMachineDescription-de_DE"
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
        let mockSequence = ["zählen", "1", "2", "3"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "zählen", value: "123"))
    }

    func testBackCommand() throws {
        // Given
        let mockSequence = ["zählen", "1", "2", "3", "codieren", "3", "zählen", "3", "zurück"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "zählen", value: "123"))
    }

    func testResetCommand() throws {
        // Given
        let mockSequence = ["zählen", "1", "2", "3", "codieren", "3", "zählen", "3", "zurücksetzen"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "zählen", value: "123"))
        XCTAssertEqual(sut.history[1], SpeechToCommandInput(command: "codieren", value: "3"))
    }

    func testOneCommandCamelCased_expectOneSaved() throws {
        // Given
        let mockSequence = ["zählen", "1", "2", "3"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "zählen", value: "123"))
    }

    func testTwoCommand_expectOneSaved() throws {
        // Given
        let mockSequence = ["zählen", "1", "2", "3", "zählen"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "zählen", value: "123"))
    }

    func testTwoCommandCount_expectOneTwoSaved() throws {
        // Given
        let mockSequence = ["zählen", "1", "2", "3", "zählen", "1"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "zählen", value: "123"))
        XCTAssertEqual(sut.history[1], SpeechToCommandInput(command: "zählen", value: "1"))
    }

    func testTwoCommandCode_expectOneTwoSaved() throws {
        // Given
        let mockSequence = ["codieren", "1", "2", "3", "codieren", "1"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "codieren", value: "123"))
        XCTAssertEqual(sut.history[1], SpeechToCommandInput(command: "codieren", value: "1"))
    }

    func testOneCommand_withOneAsParameter_expectOneCommandSaved() throws {
        // Given
        let mockSequence = ["zählen", "eins", "2", "3"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "zählen", value: "123"))
    }
}

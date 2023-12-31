//
//  Zupan_VoiceRecognitionTests.swift
//  Zupan-VoiceRecognitionTests
//
//  Created by Rodrigo Scroferneker on 15/08/2023.
//

import XCTest
import Combine
@testable import Zupan_VoiceRecognition

final class ZupanVoiceRecognitionEnTests: XCTestCase {
    let stateMachineFilename: String = "stateMachineDescription-en"
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
        let mockSequence = ["count", "1", "2", "3"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "count", value: "123"))
    }

    func testBackCommand() throws {
        // Given
        let mockSequence = ["count", "1", "2", "3", "code", "3", "count", "3", "back"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "count", value: "123"))
    }

    func testResetCommand() throws {
        // Given
        let mockSequence = ["count", "1", "2", "3", "code", "3", "count", "3", "reset"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "count", value: "123"))
        XCTAssertEqual(sut.history[1], SpeechToCommandInput(command: "code", value: "3"))
    }

    func testOneCommandCamelCased_expectOneSaved() throws {
        // Given
        let mockSequence = ["CounT", "1", "2", "3"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "count", value: "123"))
    }

    func testTwoCommand_expectOneSaved() throws {
        // Given
        let mockSequence = ["count", "1", "2", "3", "count"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "count", value: "123"))
    }

    func testTwoCommandCount_expectOneTwoSaved() throws {
        // Given
        let mockSequence = ["count", "1", "2", "3", "count", "1"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "count", value: "123"))
        XCTAssertEqual(sut.history[1], SpeechToCommandInput(command: "count", value: "1"))
    }

    func testTwoCommandCode_expectOneTwoSaved() throws {
        // Given
        let mockSequence = ["code", "1", "2", "3", "code", "1"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "code", value: "123"))
        XCTAssertEqual(sut.history[1], SpeechToCommandInput(command: "code", value: "1"))
    }

    func testOneCommand_withOneAsParameter_expectOneCommandSaved() throws {
        // Given
        let mockSequence = ["count", "one", "2", "3"]
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
        XCTAssertEqual(sut.history[0], SpeechToCommandInput(command: "count", value: "123"))
    }
}

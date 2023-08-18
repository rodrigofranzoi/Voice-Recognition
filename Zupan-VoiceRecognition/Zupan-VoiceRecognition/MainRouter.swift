//
//  MainRouter.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 17/08/2023.
//

import Foundation
import UIKit

protocol MainRouterType: Router {
    func askForMicrophonePermissionDialog()
    func microphoneNotAvailableDialog()
    func askForSpeechPermissionDialog()
    func speechNotAvailableDialog()
    func showHistory()
    func checkForPermissions(completion: @escaping (Bool) -> Void)
}

class MainRouter: MainRouterType {
    var navigationController: UINavigationController
    
    private var speechToCommandManager: SpeechToCommandManagerType
    private var speechRecognizerProvider: SpeechRecognizerProviderType
    private var speechPermissionUseCase: SpeechPermissionUseCaseType
    private var microphonePermissionUseCase: MicrophonePermissionUseCaseType
    
    init(
        navigationController: UINavigationController,
        speechToCommandManager: SpeechToCommandManagerType,
        speechRecognizerProvider: SpeechRecognizerProviderType,
        speechPermissionUseCase: SpeechPermissionUseCase,
        microphonePermissionUseCase: MicrophonePermissionUseCaseType
    ) {
        self.navigationController = navigationController
        self.speechToCommandManager = speechToCommandManager
        self.speechRecognizerProvider = speechRecognizerProvider
        self.speechPermissionUseCase = speechPermissionUseCase
        self.microphonePermissionUseCase = microphonePermissionUseCase
    }
    
    func start() {
        let vc = MainViewController(router: self, speechToCommand: speechToCommandManager, speechRecognizer: speechRecognizerProvider)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
    
    func backToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func askForMicrophonePermissionDialog() {
        let vc = DialogViewController(
            router: self,
            title: Tr.askMicPermissionTitle,
            body: Tr.askMicPermissionBody,
            buttons: [
                .init(title: Tr.continueString, action: askForMicrophonePermission),
                .init(title: Tr.cancel, action: dismiss)
            ]
        )

        navigationController.present(vc, animated: true)
    }
    
    func microphoneNotAvailableDialog() {
        let vc = DialogViewController(
            router: self,
            title: Tr.noMicPermissionTitle,
            body: Tr.noMicPermissionBody,
            buttons: [
                .init(title: Tr.openSettings, action: openSettings),
                .init(title: Tr.cancel, action: dismiss)
            ]
        )
        
        navigationController.present(vc, animated: true)
    }
    
    func askForSpeechPermissionDialog() {
        let vc = DialogViewController(
            router: self,
            title: Tr.askSpeechPermissionTitle,
            body: Tr.askSpeechPermissionBody,
            buttons: [
                .init(title: Tr.continueString, action: askForSpeechPermission),
                .init(title: Tr.cancel, action: dismiss)
            ]
        )

        navigationController.present(vc, animated: true)
    }
    
    func speechNotAvailableDialog() {
        let vc = DialogViewController(
            router: self,
            title: Tr.askSpeechPermissionTitle,
            body: Tr.askSpeechPermissionBody,
            buttons: [
                .init(title: Tr.continueString, action: openSettings),
                .init(title: Tr.cancel, action: dismiss)
            ]
        )

        navigationController.present(vc, animated: true)
    }
    
    func showHistory() {
        
    }
    
    public func checkForPermissions(completion: @escaping (Bool) -> Void) {
        let micPermission = microphonePermissionUseCase.status
        let speechPermission = speechPermissionUseCase.status
        switch (micPermission, speechPermission) {
        case ( .undetermined, _): askForMicrophonePermissionDialog()
        case ( _, .notDetermined): askForSpeechPermissionDialog()
        case ( .denied, _): microphoneNotAvailableDialog()
        case ( _, .denied): speechNotAvailableDialog()
        default: completion(true)
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        dismiss()
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func askForMicrophonePermission() {
        dismiss()
        microphonePermissionUseCase.requestAuthorization { _ in
            DispatchQueue.main.async {
                self.checkForPermissions(completion: { _ in })
            }
        }
    }
    
    private func askForSpeechPermission() {
        dismiss()
        speechPermissionUseCase.requestAuthorization { _ in
            DispatchQueue.main.async {
                self.checkForPermissions(completion: { _ in })
            }
        }
    }
}

//
//  SceneDelegate.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 15/08/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var mainRouter: MainRouterType?

    // Main Dependencies
    var speechRecognizerProvider: SpeechRecognizerProviderType?
    var speechToCommandManager: SpeechToCommandManagerType?
    var speechPermissionUseCase: SpeechPermissionUseCaseType?
    var microphonePermissionUseCase: MicrophonePermissionUseCaseType?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)

        let langId = Locale.current.language.languageCode?.identifier ?? Rules.defaultLanguage
        let identifier = Rules.availableLanguages.contains(langId) ? langId : Rules.defaultLanguage

        guard let path = Bundle.main.path(forResource: "\(Files.baseLangFilename)\(identifier)", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let stateMachineDescription = try? JSONDecoder().decode(StateMachineDescription.self, from: data) else {
            fatalError("Language not available")
        }

        let locale = Locale.init(identifier: stateMachineDescription.language)
        let speechRecognizerProvider = SpeechRecognizerProvider(locale: locale)
        let speechToCommand = SpeechToCommandManager(
            manager: speechRecognizerProvider,
            stateMachine: stateMachineDescription)
        let speechPermissionUseCase = SpeechPermissionUseCase()
        let microphonePermissionUseCase = MicrophonePermissionUseCase()

        self.speechToCommandManager = speechToCommand
        self.speechRecognizerProvider = speechRecognizerProvider
        self.speechPermissionUseCase = speechPermissionUseCase
        self.microphonePermissionUseCase = microphonePermissionUseCase

        let navController = UINavigationController()

        self.mainRouter = MainRouter(navigationController: navController,
                                     speechToCommandManager: speechToCommand,
                                     speechPermissionUseCase: speechPermissionUseCase,
                                     microphonePermissionUseCase: microphonePermissionUseCase)
        self.mainRouter?.start()

        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

//
//  MainRouter.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 17/08/2023.
//

import Foundation
import UIKit

protocol MainRouterType: Router {
    func askForMicrophonePermission()
}

class MainRouter: MainRouterType {
    var navigationController: UINavigationController
    
    private var speechToCommandManager: SpeechToCommandManagerType
    private var factory: MainRouterFactoryType
    
    init(
        navigationController: UINavigationController,
        speechToCommandManager: SpeechToCommandManagerType,
        factory: MainRouterFactoryType = MainRouterFactory()
    ) {
        self.navigationController = navigationController
        self.speechToCommandManager = speechToCommandManager
        self.factory = factory
    }
    
    func askForMicrophonePermission() {
        let vc = factory.createNoPermissionView(router: self)
        navigationController.present(vc, animated: true)
    }
    
    func start() {
        let vc = factory.createMainView(router: self, speechToCommand: speechToCommandManager)
        navigationController.pushViewController(vc, animated: false)
    }
    
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
    
    func backToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}

protocol MainRouterFactoryType {
    func createMainView(router: MainRouterType, speechToCommand: SpeechToCommandManagerType) -> UIViewController
    func createNoPermissionView(router: MainRouterType) -> UIViewController
}

struct MainRouterFactory: MainRouterFactoryType {
    func createNoPermissionView(router: MainRouterType) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        return vc
    }
    
    func createMainView(router: MainRouterType, speechToCommand: SpeechToCommandManagerType) -> UIViewController {
        return MainViewController(router: router, speechToCommand: speechToCommand)
    }
}

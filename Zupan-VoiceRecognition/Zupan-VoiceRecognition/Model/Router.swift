//
//  Router.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 17/08/2023.
//

import Foundation
import UIKit

protocol Router {
    var navigationController: UINavigationController { get set }
    
    func start()
    func dismiss()
    func backToRoot()
}

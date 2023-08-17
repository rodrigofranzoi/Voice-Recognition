//
//  MainViewController.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 15/08/2023.
//

import Foundation
import Combine
import UIKit

class MainViewController: UIViewController {
    
    private var speechToCommand: SpeechToCommandManagerType
    private var cancellables = Set<AnyCancellable>()
    
    lazy var startButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonClickStart), for: .touchUpInside)
        view.setTitle("Start Speech", for: .normal)
        view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        return view
    }()
    
    lazy var stopButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonClickStop), for: .touchUpInside)
        view.setTitle("Stop", for: .normal)
        view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        return view
    }()
    
    lazy var lastCommandLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Commands"
        view.textColor = .white
        view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.textAlignment = .center
        return view
    }()
    
    lazy var bufferLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .systemPink
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = ""
        view.textColor = .white
        view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.textAlignment = .center
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.distribution = .equalCentering
        view.axis = .vertical
        view.spacing = 20
        return view
    }()
    
    init(speechToCommand: SpeechToCommandManagerType) {
        self.speechToCommand = speechToCommand
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.addArrangedSubview(lastCommandLabel)
        stackView.addArrangedSubview(bufferLabel)
        stackView.addArrangedSubview(startButton)
        stackView.addArrangedSubview(stopButton)
        
        view.addSubview(stackView)
        setupConstraints()
    }
    
    @objc func buttonClickStart() {
        print("Button Start")
        self.speechToCommand.start()
        self.observeValues()
    }
    
    @objc func buttonClickStop() {
        print("Button Stop")
        self.speechToCommand.stop()
        self.cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }

    private func observeValues() {
        speechToCommand
            .bufferProvider
            .receive(on: RunLoop.main)
            .sink { buffer in
                self.bufferLabel.text = buffer
            }.store(in: &cancellables)
        
        speechToCommand
            .lastCommandProvider
            .receive(on: RunLoop.main)
            .sink { command in
                self.lastCommandLabel.text = command.isEmpty ? "empty" : command
            }.store(in: &cancellables)
        
        
        speechToCommand
            .historyValueProvider
            .receive(on: RunLoop.main)
            .sink { history in
                history.forEach { input in
                    print("✅ History:", input.value)
                }
            }.store(in: &cancellables)
        
        speechToCommand
            .stateProvider
            .receive(on: RunLoop.main)
            .sink { state in
                print("✅ State Changed", state.command)
            }.store(in: &cancellables)
        
        
    }
    

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


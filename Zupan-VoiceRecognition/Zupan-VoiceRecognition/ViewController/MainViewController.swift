//
//  MainViewController.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 15/08/2023.
//

import Foundation
import Combine
import UIKit

final class MainViewController: UIViewController {
    
    enum State {
        case listening
        case idle
        case blocked
    }
    
    private let router: MainRouterType

    private var speechToCommand: SpeechToCommandManagerType
    private var viewCancellables = Set<AnyCancellable>()
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var state: State = .idle
    
    lazy var startButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 100
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonClickStart), for: .touchUpInside)
        view.setTitle(Tr.startButton, for: .normal)
        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.layer.zPosition = 2
        return view
    }()
    
    lazy var stopButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(buttonClickStop), for: .touchUpInside)
        view.setTitle(Tr.stopButton, for: .normal)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    lazy var historyButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .systemGray
        view.titleLabel?.textColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
        view.setTitle(Tr.history, for: .normal)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
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
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.textAlignment = .center
        return view
    }()
    
    lazy var rulesStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .fill
        view.layer.zPosition = 2
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = Tr.rulesTitle
        view.textColor = .black
        view.font = UIFont.systemFont(ofSize: 32.0, weight: .bold)
        view.textAlignment = .left
        view.numberOfLines = 0
        return view
    }()
    
    lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = Tr.rulesDescription
        view.textColor = .black
        view.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        view.textAlignment = .left
        view.numberOfLines = 0
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalCentering
        view.axis = .vertical
        view.spacing = 20
        view.alignment = .fill
        view.layer.zPosition = 2
        return view
    }()
    
    init(router: MainRouterType,
         speechToCommand: SpeechToCommandManagerType) {
        self.speechToCommand = speechToCommand
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.addArrangedSubview(bufferLabel)
        stackView.addArrangedSubview(stopButton)
        stackView.addArrangedSubview(historyButton)
        
        rulesStackView.addArrangedSubview(titleLabel)
        rulesStackView.addArrangedSubview(descriptionLabel)
        
        view.addSubview(rulesStackView)
        view.addSubview(startButton)
        view.addSubview(stackView)
        view.backgroundColor = .white
        setupConstraints()
        observeState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.router.checkForPermissions(completion: { _ in })
    }
    
    @objc func buttonClickStart() {
        self.state = .listening
        self.speechToCommand.start()
        self.observeValues()
    }
    
    @objc func buttonClickStop() {
        self.state = .idle
        self.speechToCommand.stop()
        self.cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }

    @objc func showHistory() {
        self.router.showHistory()
    }
    
    private func observeState() {
        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .idle:
                    self?.startButton.setTitle(Tr.startButton, for: .normal)
                    self?.startButton.backgroundColor = .systemBlue
                    self?.stopButton.isHidden = true
                    self?.bufferLabel.isHidden = true
                case .blocked:
                    self?.startButton.setTitle("Error", for: .normal)
                    self?.startButton.backgroundColor = .systemRed
                    self?.stopButton.isHidden = true
                    self?.bufferLabel.isHidden = true
                case .listening:
                    self?.startButton.setTitle(Tr.empty, for: .normal)
                    self?.startButton.backgroundColor = .systemGreen
                    self?.stopButton.isHidden = false
                    self?.bufferLabel.isHidden = false
                }
            }.store(in: &viewCancellables)
    }
    
    private func createCircle() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 100
        view.layer.zPosition = 1
        view.layer.shadowColor = UIColor.systemGreen.cgColor
        view.layer.shadowRadius = 10.0
        view.layer.shadowOpacity = 0.3
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        
        self.view.addSubview(view)
        
        view.widthAnchor.constraint(equalToConstant: 200).isActive = true
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        view.centerXAnchor.constraint(equalTo: self.startButton.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.startButton.centerYAnchor).isActive = true
        
        UIView.animate(withDuration: 2, animations: {
            view.transform = CGAffineTransform(scaleX: 2, y: 2)
        }) { (finished) in
            view.removeFromSuperview()
        }
    }
    
    private func observeValues() {
        speechToCommand
            .bufferProvider
            .receive(on: RunLoop.main)
            .sink { [weak self] buffer in
                self?.createCircle()
                self?.bufferLabel.text = buffer
            }.store(in: &cancellables)
        
        speechToCommand
            .lastCommandProvider
            .receive(on: RunLoop.main)
            .sink { [weak self] command in
                self?.createCircle()
                self?.startButton.setTitle(command.isEmpty ? Tr.empty : command, for: .normal)
            }.store(in: &cancellables)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -56),
            rulesStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 56),
            rulesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            rulesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}


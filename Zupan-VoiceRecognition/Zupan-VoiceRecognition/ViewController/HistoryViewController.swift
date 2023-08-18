//
//  HistoryViewController.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 18/08/2023.
//

import Foundation
import UIKit
import Combine

final class HistoryViewController: UIViewController {
    
    private var router: MainRouterType
    private var history: [SpeechToCommandInput]
    private var speechToCommandManager: SpeechToCommandManagerType
    
    private var cancellables = Set<AnyCancellable>()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.zPosition = 2
        return view
    }()
    
    lazy var noItemLabel: UILabel = {
        let view = UILabel()
        view.textColor = .black
        view.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.textAlignment = .center
        view.text = Tr.noHistory
        view.layer.zPosition = 1
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 250).isActive = true
        return view
    }()
    
    lazy var dismissbutton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(dismissButton), for: .touchUpInside)
        view.setTitle(Tr.dismiss, for: .normal)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.zPosition = 3
        return view
    }()
    
    init(router: MainRouterType,
         speechToCommandManager: SpeechToCommandManagerType) {
        self.router = router
        self.speechToCommandManager = speechToCommandManager
        self.history = speechToCommandManager.history
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        view.backgroundColor = .white
        view.addSubview(noItemLabel)
        view.addSubview(tableView)
        view.addSubview(dismissbutton)
        addTableViewConstraints()
        observeChanges()
    }
    
    private func observeChanges() {
        speechToCommandManager
            .historyValueProvider
            .receive(on: RunLoop.main)
            .sink { [weak self] history in
                self?.history = history
                self?.tableView.reloadData()
                self?.tableView.isHidden = history.isEmpty
            }.store(in: &cancellables)
    }
    
    @objc private func dismissButton() {
        router.dismiss()
    }
    
    private func addTableViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            dismissbutton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dismissbutton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissbutton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -56),
            noItemLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noItemLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let infoCell = history[indexPath.row]
        var content = cell?.defaultContentConfiguration()
        
        content?.text = "command: \(infoCell.command)"
        content?.secondaryText = "value: \(infoCell.value)"

        cell?.contentConfiguration = content
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
}

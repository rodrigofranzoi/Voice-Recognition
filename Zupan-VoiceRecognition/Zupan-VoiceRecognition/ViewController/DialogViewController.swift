//
//  DialogViewController.swift
//  Zupan-VoiceRecognition
//
//  Created by Rodrigo Scroferneker on 17/08/2023.
//

import Foundation
import UIKit


final class DialogViewController: UIViewController {
    
    struct ButtonDialogAction {
        let title: String
        let color: UIColor
        let action: () -> Void

        static func interactive(title: String,action: @escaping () -> Void) -> Self {
            .init(title: title,color: .systemBlue, action: action)
        }
        
        static func destructible(action: @escaping () -> Void) -> Self {
            .init(title: Tr.cancel,color: .systemRed, action: action)
        }
    }
    
    private let router: MainRouterType
    private let buttons: [ButtonDialogAction]
    
    init(router: MainRouterType,
         title: String,
         body: String,
         buttons: [ButtonDialogAction] = []
    ) {
        self.router = router
        self.buttons = buttons
        super.init(nibName: nil, bundle: nil)
        self.viewTitle.text = title
        self.body.text = body
    }
    
    lazy var viewTitle: UILabel = {
        let view = UILabel()
        view.text = "Title"
        view.font = UIFont.boldSystemFont(ofSize: 24.0)
        view.textAlignment = .left
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        return view
    }()
    
    lazy var body: UILabel = {
        let view = UILabel()
        view.text = "Description"
        view.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        view.textAlignment = .left
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .fill
        return view
    }()
    
    lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalCentering
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .fill
        return view
    }()
    
    lazy var viewContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.addArrangedSubview(viewTitle)
        stackView.addArrangedSubview(body)
        stackView.addArrangedSubview(buttonStackView)
        
        buttons.forEach { button in
            let view = UIButton()
            view.setTitle(button.title, for: .normal)
            view.addAction(UIAction(handler: { _ in button.action() }), for: .touchUpInside)
            view.backgroundColor = button.color
            view.layer.cornerRadius = 10
            view.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            view.heightAnchor.constraint(equalToConstant: 40).isActive = true
            buttonStackView.addArrangedSubview(view)
        }
        
        viewContainer.addSubview(stackView)
        view.addSubview(viewContainer)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            viewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: -56),
            stackView.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: 16),
        ])
    }
}

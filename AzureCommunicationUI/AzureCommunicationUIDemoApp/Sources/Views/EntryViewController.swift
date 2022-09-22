//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import SwiftUI
import CoreGraphics

class EntryViewController: UIViewController {
    private var envConfigSubject: EnvConfigSubject

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    init(envConfigSubject: EnvConfigSubject) {
        self.envConfigSubject = envConfigSubject
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let margin: CGFloat = 32.0
        let margins = view.safeAreaLayoutGuide

        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "UI Library Sample"
        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let startSwiftUIButton = UIButton()
        startSwiftUIButton.backgroundColor = .systemBlue
        startSwiftUIButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        startSwiftUIButton.layer.cornerRadius = 8
        startSwiftUIButton.setTitle("Call - Swift UI", for: .normal)
        startSwiftUIButton.sizeToFit()
        startSwiftUIButton.translatesAutoresizingMaskIntoConstraints = false
        startSwiftUIButton.addTarget(self, action: #selector(onSwiftUIPressed), for: .touchUpInside)

        let startUiKitButton = UIButton()
        startUiKitButton.backgroundColor = .systemBlue
        startUiKitButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        startUiKitButton.layer.cornerRadius = 8
        startUiKitButton.setTitle("Call - UI Kit", for: .normal)
        startUiKitButton.sizeToFit()
        startUiKitButton.translatesAutoresizingMaskIntoConstraints = false
        startUiKitButton.addTarget(self, action: #selector(onUIKitPressed), for: .touchUpInside)

        let startChatButton = UIButton()
        startChatButton.backgroundColor = .systemBlue
        startChatButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        startChatButton.layer.cornerRadius = 8
        startChatButton.setTitle("Chat", for: .normal)
        startChatButton.sizeToFit()
        startChatButton.translatesAutoresizingMaskIntoConstraints = false
        startChatButton.addTarget(self, action: #selector(onChatPressed), for: .touchUpInside)

        let startCallWithChatButton = UIButton()
        startCallWithChatButton.backgroundColor = .systemBlue
        startCallWithChatButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        startCallWithChatButton.layer.cornerRadius = 8
        startCallWithChatButton.setTitle("CallWithChat", for: .normal)
        startCallWithChatButton.sizeToFit()
        startCallWithChatButton.translatesAutoresizingMaskIntoConstraints = false
        startCallWithChatButton.addTarget(self, action: #selector(onCallWithChatPressed), for: .touchUpInside)

        let horizontalStackView = UIStackView(arrangedSubviews: [startSwiftUIButton,
                                                       startUiKitButton])
        horizontalStackView.spacing = margin
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .fill
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(horizontalStackView)

        let verticalStackView = UIStackView(arrangedSubviews: [horizontalStackView,
                                                               startChatButton,
                                                           startCallWithChatButton])
        verticalStackView.spacing = margin
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .fillEqually
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verticalStackView)

        let versionLabel = UILabel()
        versionLabel.text = getAppVersion()
        versionLabel.sizeToFit()
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(versionLabel)

        let constraints = [
            titleLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: margin),

            verticalStackView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            verticalStackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: margin * 2),
            verticalStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: margin),
            verticalStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -margin),

            versionLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -margin)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    @objc func onSwiftUIPressed() {
        let swiftUIDemoView = SwiftUIDemoView(envConfigSubject: envConfigSubject)
        let swiftUIDemoViewHostingController = UIHostingController(rootView: swiftUIDemoView)
        swiftUIDemoViewHostingController.modalPresentationStyle = .fullScreen
        present(swiftUIDemoViewHostingController, animated: true, completion: nil)
    }

    @objc func onUIKitPressed() {
        let uiKitDemoViewController = UIKitDemoViewController(envConfigSubject: envConfigSubject)
        uiKitDemoViewController.modalPresentationStyle = .fullScreen
        present(uiKitDemoViewController, animated: true, completion: nil)
    }

    @objc func onChatPressed() {
        let chatDemoView = CredentialsView(envConfigSubject: envConfigSubject,
                                           viewType: .chat)
        let chatDemoViewHostingController = UIHostingController(rootView: chatDemoView)
        chatDemoViewHostingController.modalPresentationStyle = .fullScreen
        present(chatDemoViewHostingController, animated: true, completion: nil)
    }

    @objc func onCallWithChatPressed() {
        let chatDemoView = CredentialsView(envConfigSubject: envConfigSubject,
                                           viewType: .callWithChat)
        let chatDemoViewHostingController = UIHostingController(rootView: chatDemoView)
        chatDemoViewHostingController.modalPresentationStyle = .fullScreen
        present(chatDemoViewHostingController, animated: true, completion: nil)
    }

    func getAppVersion() -> String {
        let dictionary = Bundle.main.infoDictionary
        guard let version = dictionary?["CFBundleShortVersionString"] as? String,
              let build = dictionary?["CFBundleVersion"] as? String,
              build != "1"
        else {
            return "Version: debug"
        }
        return "Version: \(version) (\(build))"
    }
}

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
        startSwiftUIButton.setTitle("Swift UI", for: .normal)
        startSwiftUIButton.sizeToFit()
        startSwiftUIButton.translatesAutoresizingMaskIntoConstraints = false
        startSwiftUIButton.addTarget(self, action: #selector(onSwiftUIPressed), for: .touchUpInside)
        view.addSubview(startSwiftUIButton)

        let startUiKitButton = UIButton()
        startUiKitButton.backgroundColor = .systemBlue
        startUiKitButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        startUiKitButton.layer.cornerRadius = 8
        startUiKitButton.setTitle("UI Kit", for: .normal)
        startUiKitButton.sizeToFit()
        startUiKitButton.translatesAutoresizingMaskIntoConstraints = false
        startUiKitButton.addTarget(self, action: #selector(onUIKitPressed), for: .touchUpInside)
        view.addSubview(startUiKitButton)

        let stackView = UIStackView(arrangedSubviews: [startSwiftUIButton,
                                                       startUiKitButton])
        stackView.spacing = margin
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let constraints = [
            titleLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: margin),

            stackView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: margin),
            stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -margin)
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
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import UIKit
import SwiftUI
import CoreGraphics

class EntryViewController: UIViewController {
    private var envConfigSubject: EnvConfigSubject
#if DEBUG
    private var window: FloatingUITestWindow?
    private var callingSDKWrapperMock: UITestCallingSDKWrapper?
#endif
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
#if DEBUG
        let scenes = UIApplication.shared.connectedScenes
        if let windowScenes = scenes.first as? UIWindowScene {
            let callSDKWrapperMock = UITestCallingSDKWrapper()
            self.callingSDKWrapperMock = callSDKWrapperMock
            window = FloatingUITestWindow(windowScene: windowScenes)
            window?.callingSDKWrapperMock = callSDKWrapperMock
            window?.windowLevel = .alert + 1
            window?.makeKeyAndVisible()
            window?.isHidden = true
        }
#endif
    }

    init(envConfigSubject: EnvConfigSubject) {
        self.envConfigSubject = envConfigSubject
        super.init(nibName: nil, bundle: nil)
#if DEBUG
        envConfigSubject.$useMockCallingSDKHandler.sink { [weak self] newVal in
            // If callingSDK Mock is used, then show the hidden window
            self?.window?.isHidden = !newVal
        }.store(in: &cancellables)
#endif
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
        startSwiftUIButton.addTarget(self, action: #selector(onCallingSwiftUIPressed), for: .touchUpInside)

        let startUiKitButton = UIButton()
        startUiKitButton.backgroundColor = .systemBlue
        startUiKitButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        startUiKitButton.layer.cornerRadius = 8
        startUiKitButton.setTitle("Call - UI Kit", for: .normal)
        startUiKitButton.sizeToFit()
        startUiKitButton.translatesAutoresizingMaskIntoConstraints = false
        startUiKitButton.addTarget(self, action: #selector(onCallingUIKitPressed), for: .touchUpInside)

        let startChatSwiftUIButton = UIButton()
        startChatSwiftUIButton.backgroundColor = .systemBlue
        startChatSwiftUIButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        startChatSwiftUIButton.layer.cornerRadius = 8
        startChatSwiftUIButton.setTitle("Chat - Swift UI", for: .normal)
        startChatSwiftUIButton.sizeToFit()
        startChatSwiftUIButton.translatesAutoresizingMaskIntoConstraints = false
        startChatSwiftUIButton.addTarget(self, action: #selector(onChatSwiftUIPressed), for: .touchUpInside)

        let startChatUIKitButton = UIButton()
        startChatUIKitButton.backgroundColor = .systemBlue
        startChatUIKitButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        startChatUIKitButton.layer.cornerRadius = 8
        startChatUIKitButton.setTitle("Chat - UI Kit", for: .normal)
        startChatUIKitButton.sizeToFit()
        startChatUIKitButton.translatesAutoresizingMaskIntoConstraints = false
        startChatUIKitButton.addTarget(self, action: #selector(onChatUIKitPressed), for: .touchUpInside)

        let horizontalCallingStackView = UIStackView(arrangedSubviews: [
            startSwiftUIButton,
            startUiKitButton])
        horizontalCallingStackView.spacing = margin
        horizontalCallingStackView.axis = .horizontal
        horizontalCallingStackView.alignment = .fill
        horizontalCallingStackView.distribution = .fillEqually
        horizontalCallingStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(horizontalCallingStackView)

        let horizontalChatStackView = UIStackView(arrangedSubviews: [
            startChatSwiftUIButton,
            startChatUIKitButton])
        horizontalChatStackView.spacing = margin
        horizontalChatStackView.axis = .horizontal
        horizontalChatStackView.alignment = .fill
        horizontalChatStackView.distribution = .fillEqually
        horizontalChatStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(horizontalChatStackView)

        let callWithChatButton = UIButton()
        callWithChatButton.backgroundColor = .systemBlue
        callWithChatButton.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        callWithChatButton.layer.cornerRadius = 8
        callWithChatButton.setTitle("Call with Chat", for: .normal)
        callWithChatButton.sizeToFit()
        callWithChatButton.translatesAutoresizingMaskIntoConstraints = false
        callWithChatButton.addTarget(self, action: #selector(onCallWithChatPressed), for: .touchUpInside)

        let verticalStackView = UIStackView(arrangedSubviews: [
            callWithChatButton,
            horizontalCallingStackView,
            horizontalChatStackView])
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

    @objc func onCallWithChatPressed() {
        let viewModel = CallWithChatDemoViewModel(envConfigSubject: envConfigSubject)
        let swiftUIDemoView = CallWithChatDemoView(viewModel: viewModel)
        let swiftUIDemoViewHostingController = UIHostingController(rootView: swiftUIDemoView)
        swiftUIDemoViewHostingController.modalPresentationStyle = .fullScreen
        present(swiftUIDemoViewHostingController, animated: true, completion: nil)
    }

    @objc func onCallingSwiftUIPressed() {
#if DEBUG
        let swiftUIDemoView = CallingDemoView(envConfigSubject: envConfigSubject,
                                              callingSDKWrapperMock: callingSDKWrapperMock)
#else
        let swiftUIDemoView = CallingDemoView(envConfigSubject: envConfigSubject)
#endif
        let swiftUIDemoViewHostingController = UIHostingController(rootView: swiftUIDemoView)
        swiftUIDemoViewHostingController.modalPresentationStyle = .fullScreen
        present(swiftUIDemoViewHostingController, animated: true, completion: nil)
    }

    @objc func onCallingUIKitPressed() {
#if DEBUG
        let uiKitDemoViewController = CallingDemoViewController(envConfigSubject: envConfigSubject,
                                                                callingSDKHandlerMock: callingSDKWrapperMock)
#else
        let uiKitDemoViewController = CallingDemoViewController(envConfigSubject: envConfigSubject)
#endif
        uiKitDemoViewController.modalPresentationStyle = .fullScreen
        present(uiKitDemoViewController, animated: true, completion: nil)
    }

    @objc func onChatSwiftUIPressed() {
        let chatSwiftUIDemoView = ChatDemoView(
            envConfigSubject: envConfigSubject)
        let chatSwiftUIDemoHostingController = UIHostingController(rootView: chatSwiftUIDemoView)
        chatSwiftUIDemoHostingController.modalPresentationStyle = .fullScreen
        present(chatSwiftUIDemoHostingController, animated: true, completion: nil)
    }

    @objc func onChatUIKitPressed() {
        let chatUIKitDemoViewController = ChatDemoViewController(envConfigSubject: envConfigSubject)
        chatUIKitDemoViewController.modalPresentationStyle = .fullScreen
        present(chatUIKitDemoViewController, animated: true, completion: nil)
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

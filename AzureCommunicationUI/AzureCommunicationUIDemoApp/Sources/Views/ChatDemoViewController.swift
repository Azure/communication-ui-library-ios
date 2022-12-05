//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI
import AzureCommunicationUIChat
import AzureCommunicationChat
import AzureCommunicationCommon

class ChatDemoViewController: UIViewController {

    enum LayoutConstants {
        static let verticalSpacing: CGFloat = 8.0
        static let stackViewSpacingPortrait: CGFloat = 18.0
        static let stackViewSpacingLandscape: CGFloat = 12.0
        static let buttonHorizontalInset: CGFloat = 20.0
        static let buttonVerticalInset: CGFloat = 10.0
    }

    private var selectedAcsTokenType: ACSTokenType = .token
    private var acsTokenUrlTextField: UITextField!
    private var acsTokenTextField: UITextField!

    private var displayNameTextField: UITextField!
    private var userIdTextField: UITextField!
    private var endpointUrlTextField: UITextField!
    private var selectedMeetingType: ChatType = .groupChat
    private var chatThreadIdTextField: UITextField!
    private var teamsMeetingTextField: UITextField!
    private var settingsButton: UIButton!
    private var startExperienceButton: UIButton!
    private var stopButton: UIButton!
    private var acsTokenTypeSegmentedControl: UISegmentedControl!
    private var meetingTypeSegmentedControl: UISegmentedControl!
    private var stackView: UIStackView!
    private var titleLabel: UILabel!
    private var titleLabelConstraint: NSLayoutConstraint!

    // The space needed to fill the top part of the stack view,
    // in order to make the stackview content centered
    private var spaceToFullInStackView: CGFloat?
    private var userIsEditing: Bool = false
    private var isKeyboardShowing: Bool = false

    private var cancellable = Set<AnyCancellable>()
    private var envConfigSubject: EnvConfigSubject
    var chatUIClient: ChatUIClient?
    var chatAdapter: ChatThreadAdapter?
    var threadId: String?

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUIBasedOnUserInterfaceStyle()

        if UIDevice.current.orientation.isPortrait {
            stackView.spacing = LayoutConstants.stackViewSpacingPortrait
            titleLabelConstraint.constant = 32
        } else if UIDevice.current.orientation.isLandscape {
            stackView.spacing = LayoutConstants.stackViewSpacingLandscape
            titleLabelConstraint.constant = 16.0
        }
    }

    init(envConfigSubject: EnvConfigSubject) {
        self.envConfigSubject = envConfigSubject
        super.init(nibName: nil, bundle: nil)
        self.combineEnvConfigSubject()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerNotifications()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard !userIsEditing else {
            return
        }
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        let emptySpace = stackView.customSpacing(after: stackView.arrangedSubviews.first!)
        let spaceToFill = (scrollView.frame.height - (stackView.frame.height - emptySpace)) / 2
        stackView.setCustomSpacing(spaceToFill + LayoutConstants.verticalSpacing,
                                   after: stackView.arrangedSubviews.first!)
    }

    func combineEnvConfigSubject() {
        envConfigSubject.objectWillChange
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true).sink(receiveValue: { [weak self] _ in
                self?.updateFromEnvConfig()
            }).store(in: &cancellable)
    }

    func updateFromEnvConfig() {
        if !envConfigSubject.acsToken.isEmpty {
            acsTokenTextField.text = envConfigSubject.acsToken
            acsTokenTypeSegmentedControl.selectedSegmentIndex = 2
        }
        if !envConfigSubject.displayName.isEmpty {
            displayNameTextField.text = envConfigSubject.displayName
        }
        if !envConfigSubject.userId.isEmpty {
            userIdTextField.text = envConfigSubject.userId
        }
        if !envConfigSubject.endpointUrl.isEmpty {
            endpointUrlTextField.text = envConfigSubject.endpointUrl
        }
        if !envConfigSubject.threadId.isEmpty {
            chatThreadIdTextField.text = envConfigSubject.threadId
            meetingTypeSegmentedControl.selectedSegmentIndex = 1
        }

        if !envConfigSubject.teamsMeetingLink.isEmpty {
            teamsMeetingTextField.text = envConfigSubject.teamsMeetingLink
            meetingTypeSegmentedControl.selectedSegmentIndex = 2
        }
    }

    func onError(_ error: ChatCompositeError) {
        print("::::UIKitChatDemoView::getEventsHandler::onError \(error)")
        print("::::UIKitChatDemoView error.code \(error.code)")
    }

    @objc func onBackBtnPressed() {
        Task { @MainActor in
            print("Dismissing chat")
            self.dismiss(animated: true, completion: nil)
        }
    }

    func startExperience(with link: String) async {
        print("Chat is starting \(link)")

        let communicationIdentifier = CommunicationUserIdentifier(envConfigSubject.userId)
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token: envConfigSubject.acsToken) else {
            return
        }

        self.threadId = envConfigSubject.threadId
        self.chatUIClient = ChatUIClient(
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            endpoint: envConfigSubject.endpointUrl,
            displayName: envConfigSubject.displayName)
    }

    private func getTokenCredential() async throws -> CommunicationTokenCredential {
        switch selectedAcsTokenType {
        case .token:
            if let communicationTokenCredential = try? CommunicationTokenCredential(token: acsTokenTextField.text!) {
                return communicationTokenCredential
            } else {
                throw DemoError.invalidToken
            }
        case .tokenUrl:
            if let url = URL(string: acsTokenUrlTextField.text!) {
                let tokenRefresher = AuthenticationHelper.getCommunicationToken(tokenUrl: url)
                let initialToken = await AuthenticationHelper.fetchInitialToken(with: tokenRefresher)
                let refreshOptions = CommunicationTokenRefreshOptions(initialToken: initialToken,
                                                                      refreshProactively: true,
                                                                      tokenRefresher: tokenRefresher)
                if let credential = try? CommunicationTokenCredential(withOptions: refreshOptions) {
                    return credential
                }
            }
            throw DemoError.invalidToken
        }
    }

    private func getDisplayName() -> String {
        displayNameTextField.text ?? ""
    }

    private func getMeetingLink() -> String {
        switch selectedMeetingType {
        case .groupChat:
            return chatThreadIdTextField.text ?? ""
        case .teamsChat:
            return teamsMeetingTextField.text ?? ""
        }
    }

    private func showError(for errorCode: String) {
        var errorMessage = errorCode
        let errorAlert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(errorAlert,
                animated: true,
                completion: nil)
    }

    private func registerNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillHide),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillShow),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
    }

    private func updateUIBasedOnUserInterfaceStyle() {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .white
        }
    }

    @objc func onAcsTokenTypeValueChanged(_ sender: UISegmentedControl!) {
        selectedAcsTokenType = ACSTokenType(rawValue: sender.selectedSegmentIndex)!
        updateAcsTokenTypeFields()
    }
    @objc func onMeetingTypeValueChanged(_ sender: UISegmentedControl!) {
        selectedMeetingType = ChatType(rawValue: sender.selectedSegmentIndex)!
        updateMeetingTypeFields()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardShowing = true
        adjustScrollView()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        userIsEditing = false
        isKeyboardShowing = false
        adjustScrollView()
    }

    @objc func textFieldEditingDidChange() {
        startExperienceButton.isEnabled = !isStartExperienceDisabled
        updateExperieceButton()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        userIsEditing = true
        return true
    }

    @objc func onSettingsPressed() {
        let settingsView = SettingsView(envConfigSubject: envConfigSubject)
        let settingsViewHostingController = UIHostingController(rootView: settingsView)
        settingsViewHostingController.modalPresentationStyle = .formSheet
        present(settingsViewHostingController, animated: true, completion: nil)
    }

    @objc func onStartExperienceBtnPressed() {
        startExperienceButton.isEnabled = false
        startExperienceButton.backgroundColor = .systemGray3

        let link = self.getMeetingLink()
        Task { @MainActor in
            if self.chatAdapter == nil {
                await self.startExperience(with: link)
            }
            guard let chatUIClient = self.chatUIClient,
                  let threadId = self.threadId else {
                return
            }
            let chatAdapter = ChatThreadAdapter(
                chatUIClient: chatUIClient,
                threadId: threadId)
            self.chatAdapter = chatAdapter
            let chatCompositeViewController = ChatThreadViewController(
                with: chatAdapter)

            let closeItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: nil,
                action: #selector(onBackBtnPressed))
            chatCompositeViewController.title = "Chat"
            chatCompositeViewController.navigationItem.leftBarButtonItem = closeItem
            let navController = NavigationController(rootViewController: chatCompositeViewController)
            navController.modalPresentationStyle = .fullScreen

            present(navController, animated: true, completion: nil)

            startExperienceButton.isEnabled = true
            startExperienceButton.backgroundColor = .systemBlue
            updateExperieceButton()
        }
    }

    @objc func onStopBtnPressed() {
        Task { @MainActor in
            self.chatAdapter = nil
            updateExperieceButton()
        }
    }

    private func updateAcsTokenTypeFields() {
        switch selectedAcsTokenType {
        case .tokenUrl:
            acsTokenUrlTextField.isHidden = false
            acsTokenTextField.isHidden = true
        case .token:
            acsTokenUrlTextField.isHidden = true
            acsTokenTextField.isHidden = false
        }
    }

    private func updateMeetingTypeFields() {
        switch selectedMeetingType {
        case .groupChat:
            chatThreadIdTextField.isHidden = false
            teamsMeetingTextField.isHidden = true
        case .teamsChat:
            chatThreadIdTextField.isHidden = true
            teamsMeetingTextField.isHidden = false
        }
    }

    private func updateExperieceButton() {
        if isStartExperienceDisabled {
            startExperienceButton.backgroundColor = .systemGray3
        } else {
            startExperienceButton.backgroundColor = .systemBlue
        }
        if self.chatAdapter == nil {
            stopButton.backgroundColor = .systemGray3
            stopButton.isEnabled = false
        } else {
            stopButton.backgroundColor = .systemBlue
            stopButton.isEnabled = true
        }
    }

    private var isStartExperienceDisabled: Bool {
        if (selectedAcsTokenType == .token && acsTokenTextField.text!.isEmpty)
            || (selectedAcsTokenType == .tokenUrl && acsTokenUrlTextField.text!.isEmpty)
            || (userIdTextField.text!.isEmpty)
            || (endpointUrlTextField.text!.isEmpty)
            || (selectedMeetingType == .groupChat && chatThreadIdTextField.text!.isEmpty)
            || (selectedMeetingType == .teamsChat && teamsMeetingTextField.text!.isEmpty) {
            return true
        }

        return false
    }

    private func setupUI() {
        updateUIBasedOnUserInterfaceStyle()
        let safeArea = view.safeAreaLayoutGuide

        titleLabel = UILabel()
        titleLabel.text = "UI Library - UIKit Sample"
        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        titleLabelConstraint = titleLabel.topAnchor.constraint(equalTo: safeArea.topAnchor,
                                                               constant: LayoutConstants.stackViewSpacingPortrait)
        titleLabelConstraint.isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true

        acsTokenUrlTextField = UITextField()
        acsTokenUrlTextField.placeholder = "ACS Token URL"
        acsTokenUrlTextField.text = envConfigSubject.acsTokenUrl
        acsTokenUrlTextField.delegate = self
        acsTokenUrlTextField.sizeToFit()
        acsTokenUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        acsTokenUrlTextField.borderStyle = .roundedRect
        acsTokenUrlTextField.addTarget(self,
                                       action: #selector(textFieldEditingDidChange),
                                       for: .editingChanged)

        acsTokenTextField = UITextField()
        acsTokenTextField.placeholder = "ACS Token"
        acsTokenTextField.text = envConfigSubject.acsToken
        acsTokenTextField.delegate = self
        acsTokenTextField.sizeToFit()
        acsTokenTextField.translatesAutoresizingMaskIntoConstraints = false
        acsTokenTextField.borderStyle = .roundedRect
        acsTokenTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        acsTokenTypeSegmentedControl = UISegmentedControl(items: ["Token URL", "Token"])
        acsTokenTypeSegmentedControl.selectedSegmentIndex = envConfigSubject.selectedAcsTokenType.rawValue
        acsTokenTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        acsTokenTypeSegmentedControl.addTarget(self,
                                               action: #selector(onAcsTokenTypeValueChanged(_:)),
                                               for: .valueChanged)
        selectedAcsTokenType = envConfigSubject.selectedAcsTokenType

        displayNameTextField = UITextField()
        displayNameTextField.placeholder = "Display Name"
        displayNameTextField.text = envConfigSubject.displayName
        displayNameTextField.translatesAutoresizingMaskIntoConstraints = false
        displayNameTextField.delegate = self
        displayNameTextField.borderStyle = .roundedRect
        displayNameTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        userIdTextField = UITextField()
        userIdTextField.placeholder = "Communication User Id"
        userIdTextField.text = envConfigSubject.userId
        userIdTextField.translatesAutoresizingMaskIntoConstraints = false
        userIdTextField.delegate = self
        userIdTextField.borderStyle = .roundedRect
        userIdTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        endpointUrlTextField = UITextField()
        endpointUrlTextField.placeholder = "Endpoint Url"
        endpointUrlTextField.text = envConfigSubject.endpointUrl
        endpointUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        endpointUrlTextField.delegate = self
        endpointUrlTextField.borderStyle = .roundedRect
        endpointUrlTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        chatThreadIdTextField = UITextField()
        chatThreadIdTextField.placeholder = "ThreadId Id"
        chatThreadIdTextField.text = envConfigSubject.threadId
        chatThreadIdTextField.delegate = self
        chatThreadIdTextField.sizeToFit()
        chatThreadIdTextField.translatesAutoresizingMaskIntoConstraints = false
        chatThreadIdTextField.borderStyle = .roundedRect
        chatThreadIdTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        teamsMeetingTextField = UITextField()
        teamsMeetingTextField.placeholder = "Teams Meeting Link"
        teamsMeetingTextField.text = envConfigSubject.teamsMeetingLink
        teamsMeetingTextField.delegate = self
        teamsMeetingTextField.sizeToFit()
        teamsMeetingTextField.translatesAutoresizingMaskIntoConstraints = false
        teamsMeetingTextField.borderStyle = .roundedRect
        teamsMeetingTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        meetingTypeSegmentedControl = UISegmentedControl(items: ["Group Chat", "Teams Chat"])
        meetingTypeSegmentedControl.selectedSegmentIndex = envConfigSubject.selectedMeetingType.rawValue
        meetingTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        meetingTypeSegmentedControl.addTarget(self,
                                              action: #selector(onMeetingTypeValueChanged(_:)),
                                              for: .valueChanged)
        selectedMeetingType = envConfigSubject.selectedChatType

        settingsButton = UIButton()
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.backgroundColor = .systemBlue
        settingsButton.addTarget(self, action: #selector(onSettingsPressed), for: .touchUpInside)
        settingsButton.layer.cornerRadius = 8
        settingsButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                             left: LayoutConstants.buttonHorizontalInset,
                                                             bottom: LayoutConstants.buttonVerticalInset,
                                                             right: LayoutConstants.buttonHorizontalInset)

        startExperienceButton = UIButton()
        startExperienceButton.backgroundColor = .systemBlue
        startExperienceButton.setTitleColor(UIColor.white, for: .normal)
        startExperienceButton.setTitleColor(UIColor.systemGray6, for: .disabled)
        startExperienceButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                                    left: LayoutConstants.buttonHorizontalInset,
                                                                    bottom: LayoutConstants.buttonVerticalInset,
                                                                    right: LayoutConstants.buttonHorizontalInset)
        startExperienceButton.layer.cornerRadius = 8
        startExperienceButton.setTitle("Start Experience", for: .normal)
        startExperienceButton.sizeToFit()
        startExperienceButton.translatesAutoresizingMaskIntoConstraints = false
        startExperienceButton.addTarget(self, action: #selector(onStartExperienceBtnPressed), for: .touchUpInside)

        startExperienceButton.accessibilityLabel = AccessibilityId.startExperienceAccessibilityID.rawValue

        stopButton = UIButton()
        stopButton.backgroundColor = .systemGray6
        stopButton.setTitleColor(UIColor.white, for: .normal)
        stopButton.setTitleColor(UIColor.systemGray6, for: .disabled)
        stopButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                         left: LayoutConstants.buttonHorizontalInset,
                                                         bottom: LayoutConstants.buttonVerticalInset,
                                                         right: LayoutConstants.buttonHorizontalInset)
        stopButton.layer.cornerRadius = 8
        stopButton.setTitle("Stop", for: .normal)
        stopButton.sizeToFit()
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(onStopBtnPressed), for: .touchUpInside)

        stopButton.accessibilityLabel = AccessibilityId.stopChatAccessibilityID.rawValue

        // horizontal stack view for the settingButton and startExperienceButton
        let settingButtonHSpacer1 = UIView()
        settingButtonHSpacer1.translatesAutoresizingMaskIntoConstraints = false
        settingButtonHSpacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let settingButtonHSpacer2 = UIView()
        settingButtonHSpacer2.translatesAutoresizingMaskIntoConstraints = false
        settingButtonHSpacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let settingsButtonHStack = UIStackView(arrangedSubviews: [settingButtonHSpacer1,
                                                                  settingsButton,
                                                                  settingButtonHSpacer2])
        settingsButtonHStack.axis = .horizontal
        settingsButtonHStack.alignment = .fill
        settingsButtonHStack.distribution = .fill
        settingsButtonHStack.translatesAutoresizingMaskIntoConstraints = false

        let startButtonHSpacer1 = UIView()
        startButtonHSpacer1.translatesAutoresizingMaskIntoConstraints = false
        startButtonHSpacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let startButtonHSpacer2 = UIView()
        startButtonHSpacer2.translatesAutoresizingMaskIntoConstraints = false
        startButtonHSpacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let startButtonHStack = UIStackView(arrangedSubviews: [startButtonHSpacer1,
                                                               startExperienceButton,
                                                               startButtonHSpacer2,
                                                               stopButton,
                                                               startButtonHSpacer2])
        startButtonHStack.axis = .horizontal
        startButtonHStack.alignment = .fill
        startButtonHStack.distribution = .fill
        startButtonHStack.translatesAutoresizingMaskIntoConstraints = false

        let spaceView1 = UIView()
        spaceView1.translatesAutoresizingMaskIntoConstraints = false
        spaceView1.heightAnchor.constraint(equalToConstant: 0).isActive = true

        stackView = UIStackView(arrangedSubviews: [spaceView1,
                                                   acsTokenTypeSegmentedControl,
                                                   acsTokenUrlTextField,
                                                   acsTokenTextField,
                                                   displayNameTextField,
                                                   userIdTextField,
                                                   endpointUrlTextField,
                                                   meetingTypeSegmentedControl,
                                                   chatThreadIdTextField,
                                                   teamsMeetingTextField,
                                                   settingsButtonHStack,
                                                   startButtonHStack])
        stackView.spacing = LayoutConstants.stackViewSpacingPortrait
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setCustomSpacing(0, after: stackView.arrangedSubviews.first!)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                        constant: LayoutConstants.verticalSpacing).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true

        contentView.addSubview(stackView)
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                           constant: LayoutConstants.stackViewSpacingPortrait).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                            constant: LayoutConstants.stackViewSpacingPortrait).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        settingButtonHSpacer2.widthAnchor.constraint(equalTo: settingButtonHSpacer1.widthAnchor).isActive = true
        startButtonHSpacer2.widthAnchor.constraint(equalTo: startButtonHSpacer1.widthAnchor).isActive = true

        updateAcsTokenTypeFields()
        updateMeetingTypeFields()
        startExperienceButton.isEnabled = !isStartExperienceDisabled
        updateExperieceButton()
    }

    private func adjustScrollView() {
        if UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.orientation.isLandscape {
            if self.isKeyboardShowing {
                let offset: CGFloat = (UIDevice.current.orientation.isPortrait
                              || UIDevice.current.orientation == .unknown) ? 200 : 250
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
                scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            } else {
                scrollView.contentInset = .zero
                scrollView.scrollIndicatorInsets = .zero
            }
        }
    }
}

extension ChatDemoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

class NavigationController: UINavigationController {
    override var shouldAutorotate: Bool {
        false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }
}

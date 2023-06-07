//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI
import AzureCommunicationCommon
import AppCenterCrashes
import AVFoundation
#if DEBUG
@testable import AzureCommunicationUICalling
#else
import AzureCommunicationUICalling
#endif

class CallingDemoViewController: UIViewController {

    enum LayoutConstants {
        static let verticalSpacing: CGFloat = 8.0
        static let stackViewSpacingPortrait: CGFloat = 18.0
        static let stackViewSpacingLandscape: CGFloat = 12.0
        static let buttonHorizontalInset: CGFloat = 20.0
        static let buttonVerticalInset: CGFloat = 10.0
    }
    var callingViewModel: CallingDemoViewModel

    private var selectedAcsTokenType: ACSTokenType = .token
    private var acsTokenUrlTextField: UITextField!
    private var acsTokenTextField: UITextField!
    private var selectedMeetingType: MeetingType = .groupCall
    private var displayNameTextField: UITextField!
    private var groupCallTextField: UITextField!
    private var teamsMeetingTextField: UITextField!
    private var settingsButton: UIButton!
    private var showCallHistoryButton: UIButton!
    private var startExperienceButton: UIButton!
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
#if DEBUG
    private var callingSDKWrapperMock: UITestCallingSDKWrapper?
#endif
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

#if DEBUG
    init(envConfigSubject: EnvConfigSubject,
         callingViewModel: CallingDemoViewModel,
         callingSDKHandlerMock: UITestCallingSDKWrapper? = nil) {
        self.envConfigSubject = envConfigSubject
        self.callingViewModel = callingViewModel
        self.callingSDKWrapperMock = callingSDKHandlerMock
        super.init(nibName: nil, bundle: nil)
        self.combineEnvConfigSubject()
    }
#else
    init(envConfigSubject: EnvConfigSubject,
         callingViewModel: CallingDemoViewModel) {
        self.envConfigSubject = envConfigSubject
        self.callingViewModel = callingViewModel
        super.init(nibName: nil, bundle: nil)
        self.combineEnvConfigSubject()
    }
#endif
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

    private func combineEnvConfigSubject() {
        envConfigSubject.objectWillChange
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true).sink(receiveValue: { [weak self] _ in
                self?.updateFromEnvConfig()
            }).store(in: &cancellable)
    }

    private func updateFromEnvConfig() {
        if envConfigSubject.useExpiredToken {
            updateToken(envConfigSubject.expiredAcsToken)
        } else {
            updateToken(envConfigSubject.acsToken)
        }

        if !envConfigSubject.displayName.isEmpty {
            displayNameTextField.text = envConfigSubject.displayName
        }

        if !envConfigSubject.groupCallId.isEmpty {
            groupCallTextField.text = envConfigSubject.groupCallId
        }

        if !envConfigSubject.teamsMeetingLink.isEmpty {
            teamsMeetingTextField.text = envConfigSubject.teamsMeetingLink
        }

        if envConfigSubject.selectedMeetingType == .groupCall {
            meetingTypeSegmentedControl.selectedSegmentIndex = 0
        } else if envConfigSubject.selectedMeetingType == .teamsMeeting {
            meetingTypeSegmentedControl.selectedSegmentIndex = 1
        }
    }

    private func updateToken(_ token: String) {
        if !token.isEmpty {
            acsTokenTextField.text = token
            acsTokenTypeSegmentedControl.selectedSegmentIndex = 1
        }
    }

    private func onError(_ error: CallCompositeError, callComposite: CallComposite) {
        print("::::UIKitDemoView::getEventsHandler::onError \(error)")
        print("::::UIKitDemoView error.code \(error.code)")
        callingViewModel.callHistory.last?.callIds.forEach { print("::::UIKitDemoView call id \($0)") }
    }

    private func onRemoteParticipantJoined(to callComposite: CallComposite, identifiers: [CommunicationIdentifier]) {
        print("::::UIKitDemoView::getEventsHandler::onRemoteParticipantJoined \(identifiers)")
        guard envConfigSubject.useCustomRemoteParticipantViewData else {
            return
        }

        RemoteParticipantAvatarHelper.onRemoteParticipantJoined(to: callComposite,
                                                                identifiers: identifiers)
    }

    private func startExperience(with link: String) async {
        var localizationConfig: LocalizationOptions?
        let layoutDirection: LayoutDirection = envConfigSubject.isRightToLeft ? .rightToLeft : .leftToRight
        if !envConfigSubject.localeIdentifier.isEmpty {
            let locale = Locale(identifier: envConfigSubject.localeIdentifier)
            localizationConfig = LocalizationOptions(locale: locale,
                                                           layoutDirection: layoutDirection)
        } else if !envConfigSubject.locale.identifier.isEmpty {
            localizationConfig = LocalizationOptions(
                locale: envConfigSubject.locale,
                layoutDirection: layoutDirection)
        }

        let callCompositeOptions = CallCompositeOptions(
            theme: envConfigSubject.useCustomColors
            ? CustomColorTheming(envConfigSubject: envConfigSubject)
            : Theming(envConfigSubject: envConfigSubject),
            localization: localizationConfig)
        #if DEBUG
        let callComposite = envConfigSubject.useMockCallingSDKHandler ?
            CallComposite(withOptions: callCompositeOptions,
                          callingSDKWrapperProtocol: callingSDKWrapperMock)
            : CallComposite(withOptions: callCompositeOptions)
        #else
        let callComposite = CallComposite(withOptions: callCompositeOptions)
        #endif
        let onRemoteParticipantJoinedHandler: ([CommunicationIdentifier]) -> Void = { [weak callComposite] ids in
            guard let composite = callComposite else {
                return
            }
            self.onRemoteParticipantJoined(to: composite,
                                           identifiers: ids)
        }
        let onErrorHandler: (CallCompositeError) -> Void = { [weak callComposite] error in
            guard let composite = callComposite else {
                return
            }
            self.onError(error,
                         callComposite: composite)
        }
        callComposite.events.onRemoteParticipantJoined = onRemoteParticipantJoinedHandler
        callComposite.events.onError = onErrorHandler

        let renderDisplayName = envConfigSubject.renderedDisplayName.isEmpty ?
                                nil : envConfigSubject.renderedDisplayName
        let setupScreenViewData = SetupScreenViewData(title: envConfigSubject.navigationTitle,
                                                          subtitle: envConfigSubject.navigationSubtitle)
        let participantViewData = ParticipantViewData(avatar: UIImage(named: envConfigSubject.avatarImageName),
                                                      displayName: renderDisplayName)
        let localOptions = LocalOptions(participantViewData: participantViewData,
                                        setupScreenViewData: setupScreenViewData,
                                        cameraOn: envConfigSubject.cameraOn,
                                        microphoneOn: envConfigSubject.microphoneOn,
                                        skipSetupScreen: envConfigSubject.skipSetupScreen)
        let enableCallKit = envConfigSubject.enableCallKit

        if let credential = try? await getTokenCredential() {
            switch selectedMeetingType {
            case .groupCall:
                let uuid = UUID(uuidString: link) ?? UUID()
                callComposite.launch(remoteOptions: RemoteOptions(for: .groupCall(groupId: uuid),
                                                                  credential: credential,
                                                                  displayName: getDisplayName(),
                                                                  enableCallKit: enableCallKit),
                                     localOptions: localOptions)
            case .teamsMeeting:
                callComposite.launch(remoteOptions: RemoteOptions(for: .teamsMeeting(teamsLink: link),
                                                                  credential: credential,
                                                                  displayName: getDisplayName(),
                                                                  enableCallKit: enableCallKit),
                                     localOptions: localOptions)
            }
        } else {
            showError(for: DemoError.invalidToken.getErrorCode())
            return
        }
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
                let tokenRefresher = AuthenticationHelper.getCommunicationToken(tokenUrl: url,
                                                                                aadToken: envConfigSubject.aadToken)
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
        case .groupCall:
            return groupCallTextField.text ?? ""
        case .teamsMeeting:
            return teamsMeetingTextField.text ?? ""
        }
    }

    private func showError(for errorCode: String) {
        var errorMessage = ""
        switch errorCode {
        case CallCompositeErrorCode.tokenExpired:
            errorMessage = "Token is invalid"
        case CallCompositeErrorCode.microphonePermissionNotGranted:
            errorMessage = "Microphone Permission is denied"
        case CallCompositeErrorCode.networkConnectionNotAvailable:
            errorMessage = "Internet error"
        default:
            errorMessage = "Unknown error"
        }
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
        selectedMeetingType = MeetingType(rawValue: sender.selectedSegmentIndex)!
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
        updateStartExperieceButton()
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

    @objc func onShowHistoryBtnPressed() {
        let errorAlert = UIAlertController(title: callingViewModel.callHistoryTitle,
                                           message: callingViewModel.callHistoryMessage,
                                           preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(errorAlert,
                animated: true,
                completion: nil)
    }

    @objc func onStartExperienceBtnPressed() {
        startExperienceButton.isEnabled = false
        startExperienceButton.backgroundColor = .systemGray3

        let link = self.getMeetingLink()
        Task { @MainActor in
            if getAudioPermissionStatus() == .denied && envConfigSubject.skipSetupScreen {
                showError(for: CallCompositeErrorCode.microphonePermissionNotGranted)
                startExperienceButton.isEnabled = true
                startExperienceButton.backgroundColor = .systemBlue
                return
            }
            await self.startExperience(with: link)
            startExperienceButton.isEnabled = true
            startExperienceButton.backgroundColor = .systemBlue
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
        case .groupCall:
            groupCallTextField.isHidden = false
            teamsMeetingTextField.isHidden = true
        case .teamsMeeting:
            groupCallTextField.isHidden = true
            teamsMeetingTextField.isHidden = false
        }
    }

    private func updateStartExperieceButton() {
        if isStartExperienceDisabled {
            startExperienceButton.backgroundColor = .systemGray3
        } else {
            startExperienceButton.backgroundColor = .systemBlue
        }
    }

    private var isStartExperienceDisabled: Bool {
        if (selectedAcsTokenType == .token && acsTokenTextField.text!.isEmpty)
            || (selectedAcsTokenType == .tokenUrl && acsTokenUrlTextField.text!.isEmpty)
            || (selectedMeetingType == .groupCall && groupCallTextField.text!.isEmpty)
            || (selectedMeetingType == .teamsMeeting && teamsMeetingTextField.text!.isEmpty) {
            return true
        }

        return false
    }

    private func getAudioPermissionStatus() -> AVAudioSession.RecordPermission {
            return AVAudioSession.sharedInstance().recordPermission
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

        groupCallTextField = UITextField()
        groupCallTextField.placeholder = "Group Call Id"
        groupCallTextField.text = envConfigSubject.groupCallId
        groupCallTextField.delegate = self
        groupCallTextField.sizeToFit()
        groupCallTextField.translatesAutoresizingMaskIntoConstraints = false
        groupCallTextField.borderStyle = .roundedRect
        groupCallTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        teamsMeetingTextField = UITextField()
        teamsMeetingTextField.placeholder = "Teams Meeting Link"
        teamsMeetingTextField.text = envConfigSubject.teamsMeetingLink
        teamsMeetingTextField.delegate = self
        teamsMeetingTextField.sizeToFit()
        teamsMeetingTextField.translatesAutoresizingMaskIntoConstraints = false
        teamsMeetingTextField.borderStyle = .roundedRect
        teamsMeetingTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        meetingTypeSegmentedControl = UISegmentedControl(items: ["Group Call", "Teams Meeting"])
        meetingTypeSegmentedControl.selectedSegmentIndex = envConfigSubject.selectedMeetingType.rawValue
        meetingTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        meetingTypeSegmentedControl.addTarget(self,
                                              action: #selector(onMeetingTypeValueChanged(_:)),
                                              for: .valueChanged)
        selectedMeetingType = envConfigSubject.selectedMeetingType

        settingsButton = UIButton()
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.backgroundColor = .systemBlue
        settingsButton.addTarget(self, action: #selector(onSettingsPressed), for: .touchUpInside)
        settingsButton.layer.cornerRadius = 8
        settingsButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                             left: LayoutConstants.buttonHorizontalInset,
                                                             bottom: LayoutConstants.buttonVerticalInset,
                                                             right: LayoutConstants.buttonHorizontalInset)
        settingsButton.accessibilityIdentifier = AccessibilityId.settingsButtonAccessibilityID.rawValue

        showCallHistoryButton = UIButton()
        showCallHistoryButton.setTitle("Show call history", for: .normal)
        showCallHistoryButton.backgroundColor = .systemBlue
        showCallHistoryButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                                    left: LayoutConstants.buttonHorizontalInset,
                                                                    bottom: LayoutConstants.buttonVerticalInset,
                                                                    right: LayoutConstants.buttonHorizontalInset)
        showCallHistoryButton.layer.cornerRadius = 8
        showCallHistoryButton.addTarget(self, action: #selector(onShowHistoryBtnPressed), for: .touchUpInside)

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

        let showHistoryButtonHSpacer1 = UIView()
        showHistoryButtonHSpacer1.translatesAutoresizingMaskIntoConstraints = false
        showHistoryButtonHSpacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let showHistoryButtonHSpacer2 = UIView()
        showHistoryButtonHSpacer2.translatesAutoresizingMaskIntoConstraints = false
        showHistoryButtonHSpacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let showHistoryButtonHStack = UIStackView(arrangedSubviews: [showHistoryButtonHSpacer1,
                                                                  showCallHistoryButton,
                                                                  showHistoryButtonHSpacer2])
        showHistoryButtonHStack.axis = .horizontal
        showHistoryButtonHStack.alignment = .fill
        showHistoryButtonHStack.distribution = .fill
        showHistoryButtonHStack.translatesAutoresizingMaskIntoConstraints = false

        let startButtonHSpacer1 = UIView()
        startButtonHSpacer1.translatesAutoresizingMaskIntoConstraints = false
        startButtonHSpacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let startButtonHSpacer2 = UIView()
        startButtonHSpacer2.translatesAutoresizingMaskIntoConstraints = false
        startButtonHSpacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let startButtonHStack = UIStackView(arrangedSubviews: [startButtonHSpacer1,
                                                               startExperienceButton,
                                                               startButtonHSpacer2])
        startButtonHStack.axis = .horizontal
        startButtonHStack.alignment = .fill
        startButtonHStack.distribution = .fill
        startButtonHStack.translatesAutoresizingMaskIntoConstraints = false

        let spaceView1 = UIView()
        spaceView1.translatesAutoresizingMaskIntoConstraints = false
        spaceView1.heightAnchor.constraint(equalToConstant: 0).isActive = true

        stackView = UIStackView(arrangedSubviews: [spaceView1, acsTokenTypeSegmentedControl,
                                                   acsTokenUrlTextField,
                                                   acsTokenTextField,
                                                   displayNameTextField,
                                                   meetingTypeSegmentedControl,
                                                   groupCallTextField,
                                                   teamsMeetingTextField,
                                                   settingsButtonHStack,
                                                   showHistoryButtonHStack,
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
                                            constant: -LayoutConstants.stackViewSpacingPortrait).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        settingButtonHSpacer2.widthAnchor.constraint(equalTo: settingButtonHSpacer1.widthAnchor).isActive = true
        showHistoryButtonHSpacer2.widthAnchor.constraint(equalTo: showHistoryButtonHSpacer1.widthAnchor).isActive = true
        startButtonHSpacer2.widthAnchor.constraint(equalTo: startButtonHSpacer1.widthAnchor).isActive = true

        updateAcsTokenTypeFields()
        updateMeetingTypeFields()
        startExperienceButton.isEnabled = !isStartExperienceDisabled
        updateStartExperieceButton()
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

extension CallingDemoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

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
import CallKit
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
    private var userIdTextField: UITextField!
    private var groupCallTextField: UITextField!
    private var teamsMeetingTextField: UITextField!
    private var teamsMeetingIdTextField: UITextField!
    private var teamsMeetingPasscodeTextField: UITextField!
    private var participantMRIsTextField: UITextField!
    private var roomCallTextField: UITextField!
    private var settingsButton: UIButton!
    private var showCallHistoryButton: UIButton!
    private var registerPushButton: UIButton!
    private var unregisterPushButton: UIButton!
    private var acceptCallButton: UIButton!
    private var declineCallButton: UIButton!
    private var startExperienceButton: UIButton!
    private var showExperienceButton: UIButton!
    private var acsTokenTypeSegmentedControl: UISegmentedControl!
    private var meetingTypeSegmentedControl: UISegmentedControl!
    private var stackView: UIStackView!
    private var titleLabel: UILabel!
    private var callStateLabel: UILabel!
    private var titleLabelConstraint: NSLayoutConstraint!
    private var callStateLabelConstraint: NSLayoutConstraint!
    private var incomingCallId = ""
    private var isIncomingCall = false

    // The space needed to fill the top part of the stack view,
    // in order to make the stackview content centered
    private var spaceToFullInStackView: CGFloat?
    private var userIsEditing = false
    private var isKeyboardShowing = false
    private var exitCompositeExecuted = false

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

        if !envConfigSubject.userId.isEmpty {
            userIdTextField.text = envConfigSubject.userId
        }

        if !envConfigSubject.groupCallId.isEmpty {
            groupCallTextField.text = envConfigSubject.groupCallId
        }

        if !envConfigSubject.teamsMeetingLink.isEmpty {
            teamsMeetingTextField.text = envConfigSubject.teamsMeetingLink
        }
        if !envConfigSubject.teamsMeetingId.isEmpty {
            teamsMeetingIdTextField.text = envConfigSubject.teamsMeetingId
        }
        if !envConfigSubject.teamsMeetingPasscode.isEmpty {
            teamsMeetingPasscodeTextField.text = envConfigSubject.teamsMeetingPasscode
        }
        if !envConfigSubject.participantMRIs.isEmpty {
            participantMRIsTextField.text = envConfigSubject.participantMRIs
        }
        if envConfigSubject.selectedMeetingType == .groupCall {
            meetingTypeSegmentedControl.selectedSegmentIndex = 0
        } else if envConfigSubject.selectedMeetingType == .teamsMeeting {
            meetingTypeSegmentedControl.selectedSegmentIndex = 1
        }
        if !envConfigSubject.roomId.isEmpty {
            roomCallTextField.text = envConfigSubject.roomId
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

    private func onCallStateChanged(_ callState: CallState, callComposite: CallComposite) {
        print("::::CallingDemoViewController::getEventsHandler::onCallStateChanged \(callState.requestString)")
        callStateLabel.text = callState.requestString
    }

    func createCallComposite() async -> CallComposite? {
        print("CallingDemoView:::: createCallComposite requesting")
        if GlobalCompositeManager.callComposite != nil {
            print("CallingDemoView:::: createCallComposite exist")
            return GlobalCompositeManager.callComposite!
        }
        print("CallingDemoView:::: createCallComposite creating")
        var localizationConfig: LocalizationOptions?
        let layoutDirection: LayoutDirection = envConfigSubject.isRightToLeft ? .rightToLeft : .leftToRight
        let barOptions = CallScreenControlBarOptions(leaveCallConfirmationMode:
                                                        envConfigSubject.displayLeaveCallConfirmation ?
            .alwaysEnabled : .alwaysDisabled)
        if !envConfigSubject.localeIdentifier.isEmpty {
            let locale = Locale(identifier: envConfigSubject.localeIdentifier)
            localizationConfig = LocalizationOptions(locale: locale,
                                                           layoutDirection: layoutDirection)
        } else if !envConfigSubject.locale.identifier.isEmpty {
            localizationConfig = LocalizationOptions(
                locale: envConfigSubject.locale,
                layoutDirection: layoutDirection)
        }
        var callDurationCustomTimer = CallCompositeCallDurationCustomTimer()
        var callScreenOptions = CallScreenOptions(controlBarOptions: barOptions,
                                                  callScreenHeaderOptions: CallCompositeCallScreenHeaderOptions(
                                                    customTimer: callDurationCustomTimer))
        let setupViewOrientation = envConfigSubject.setupViewOrientation
        let setupScreenOptions = SetupScreenOptions(
            cameraButtonEnabled: envConfigSubject.setupScreenOptionsCameraButtonEnabled,
            microphoneButtonEnabled: envConfigSubject.setupScreenOptionsMicButtonEnabled)
        let callingViewOrientation = envConfigSubject.callingViewOrientation
        let callKitOptions = envConfigSubject.enableCallKit ? getCallKitOptions() : nil
        let userId = CommunicationUserIdentifier(envConfigSubject.userId)

        let callCompositeOptions = envConfigSubject.useDeprecatedLaunch ? CallCompositeOptions(
            theme: envConfigSubject.useCustomColors
            ? CustomColorTheming(envConfigSubject: envConfigSubject)
            : Theming(envConfigSubject: envConfigSubject),
            localization: localizationConfig,
            setupScreenOrientation: setupViewOrientation,
            callingScreenOrientation: callingViewOrientation,
            enableMultitasking: envConfigSubject.enableMultitasking,
            enableSystemPictureInPictureWhenMultitasking: envConfigSubject.enablePipWhenMultitasking,
            callScreenOptions: callScreenOptions,
            callKitOptions: callKitOptions,
            setupScreenOptions: setupScreenOptions) :
        CallCompositeOptions(
            theme: envConfigSubject.useCustomColors
            ? CustomColorTheming(envConfigSubject: envConfigSubject)
            : Theming(envConfigSubject: envConfigSubject),
            localization: localizationConfig,
            setupScreenOrientation: setupViewOrientation,
            callingScreenOrientation: callingViewOrientation,
            enableMultitasking: envConfigSubject.enableMultitasking,
            enableSystemPictureInPictureWhenMultitasking: envConfigSubject.enablePipWhenMultitasking,
            callScreenOptions: callScreenOptions,
            callKitOptions: callKitOptions,
            displayName: envConfigSubject.displayName,
            disableInternalPushForIncomingCall: envConfigSubject.disableInternalPushForIncomingCall,
            setupScreenOptions: setupScreenOptions)

        let useMockCallingSDKHandler = envConfigSubject.useMockCallingSDKHandler
        if let credential = try? await getTokenCredential() {
            #if DEBUG
            let callComposite = useMockCallingSDKHandler ?
                CallComposite(withOptions: callCompositeOptions,
                              callingSDKWrapperProtocol: callingSDKWrapperMock)
            : ( envConfigSubject.useDeprecatedLaunch ?
                CallComposite(withOptions: callCompositeOptions) :
                    CallComposite(credential: credential, withOptions: callCompositeOptions))

            callingSDKWrapperMock?.callComposite = callComposite

            #else
            let callComposite = envConfigSubject.useDeprecatedLaunch ?
            CallComposite(withOptions: callCompositeOptions) :
                CallComposite(credential: credential, withOptions: callCompositeOptions)
            #endif
            subscribeToEvents(callComposite: callComposite)
            GlobalCompositeManager.callComposite = callComposite
            self.envConfigSubject.saveFromState()
            return callComposite
        }
        return nil
    }

    func subscribeToEvents(callComposite: CallComposite) {
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

        let onPipChangedHandler: (Bool) -> Void = { isPictureInPicture in
            print("::::CallingDemoView:onPipChangedHandler: ", isPictureInPicture)
        }

        let onUserReportedIssueHandler: (CallCompositeUserReportedIssue) -> Void = { issue in
            print("::::UIKitDemoView::getEventsHandler::onUserReportedIssue \(issue)")
        }

        let onCallStateChangedHandler: (CallState) -> Void = { [weak callComposite] callStateEvent in
            guard let composite = callComposite else {
                return
            }
            self.onCallStateChanged(callStateEvent,
                    callComposite: composite)
        }
        let onDismissedHandler: (CallCompositeDismissed) -> Void = { [] _ in
            if self.envConfigSubject.useRelaunchOnDismissedToggle && self.exitCompositeExecuted {
                            DispatchQueue.main.async {
                                Task { @MainActor in
                                    self.onStartExperienceBtnPressed()
                                }
                            }
                        }
        }

        exitCompositeExecuted = false
        if !envConfigSubject.exitCompositeAfterDuration.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() +
                                          Float64(envConfigSubject.exitCompositeAfterDuration)!
            ) { [weak callComposite] in
                self.exitCompositeExecuted = true
                callComposite?.dismiss()
            }
        }

        let callKitCallAccepted: (String) -> Void = { [weak callComposite] callId in
            self.acceptCallButton.isHidden = true
            self.declineCallButton.isHidden = true
            callComposite?.launch(callIdAcceptedFromCallKit: callId, localOptions: self.getLocalOptions())
        }

        let onIncomingCall: (IncomingCall) -> Void = { [] incomingCall in
            self.incomingCallId = incomingCall.callId
            self.isIncomingCall = true
            self.acceptCallButton.isHidden = false
            self.declineCallButton.isHidden = false
        }

        let onIncomingCallCancelled: (IncomingCallCancelled) -> Void = { [] _ in
            self.isIncomingCall = false
            self.acceptCallButton.isHidden = true
            self.declineCallButton.isHidden = true
        }

        callComposite.events.onRemoteParticipantJoined = onRemoteParticipantJoinedHandler
        callComposite.events.onError = onErrorHandler
        callComposite.events.onCallStateChanged = onCallStateChangedHandler
        callComposite.events.onDismissed = onDismissedHandler
        callComposite.events.onPictureInPictureChanged = onPipChangedHandler
        callComposite.events.onUserReportedIssue = onUserReportedIssueHandler
        callComposite.events.onIncomingCallAcceptedFromCallKit = callKitCallAccepted
        callComposite.events.onIncomingCall = onIncomingCall
        callComposite.events.onIncomingCallCancelled = onIncomingCallCancelled
    }

    func getLocalOptions() -> LocalOptions {
        let renderDisplayName = envConfigSubject.renderedDisplayName.isEmpty ?
                                nil : envConfigSubject.renderedDisplayName
        let participantViewData = ParticipantViewData(avatar: UIImage(named: envConfigSubject.avatarImageName),
                                                      displayName: renderDisplayName)
        let setupScreenViewData = SetupScreenViewData(title: envConfigSubject.navigationTitle,
                                                          subtitle: envConfigSubject.navigationSubtitle)
        return LocalOptions(participantViewData: participantViewData,
                                        setupScreenViewData: setupScreenViewData,
                                        cameraOn: envConfigSubject.cameraOn,
                                        microphoneOn: envConfigSubject.microphoneOn,
                                        skipSetupScreen: envConfigSubject.skipSetupScreen,
                                        audioVideoMode: envConfigSubject.audioOnly ? .audioOnly : .audioAndVideo
        )
    }

    func startCallWithDeprecatedLaunch() async {
        if let credential = try? await getTokenCredential(),
           let callComposite = try? await createCallComposite() {
            let link = getMeetingLink()
            var localOptions = getLocalOptions()
            switch selectedMeetingType {
            case .groupCall:
                let uuid = UUID(uuidString: link) ?? UUID()
                callComposite.launch(remoteOptions: RemoteOptions(for: .groupCall(groupId: uuid),
                                                                  credential: credential,
                                                                  displayName: getDisplayName()),
                                     localOptions: localOptions)
            case .teamsMeeting:
                if !teamsMeetingTextField.text!.isEmpty {
                    callComposite.launch(
                        remoteOptions: RemoteOptions(for: .teamsMeeting(teamsLink: link),
                                                     credential: credential,
                                                     displayName: getDisplayName()),
                        localOptions: localOptions
                    )
                } else if !teamsMeetingIdTextField.text!.isEmpty && !teamsMeetingPasscodeTextField.text!.isEmpty {
                    callComposite.launch(
                        remoteOptions: RemoteOptions(for: .teamsMeetingId(meetingId: teamsMeetingIdTextField.text!,
                                                                          meetingPasscode:
                                                                            teamsMeetingPasscodeTextField.text!),
                                                     credential: credential,
                                                     displayName: getDisplayName()),
                        localOptions: localOptions
                    )
                }
            case.oneToNCall:
                let ids: [String] = link.split(separator: ",").map {
                    String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                let communicationIdentifiers: [CommunicationIdentifier] =
                ids.map { createCommunicationIdentifier(fromRawId: $0) }
                callComposite.launch(participants: communicationIdentifiers,
                                     localOptions: localOptions)
            case .roomCall:
                callComposite.launch(remoteOptions:
                                        RemoteOptions(for:
                                                .roomCall(roomId: link),
                                                      credential: credential, displayName: getDisplayName()),
                                     localOptions: localOptions)
            }
        }
    }

    private func startExperience(with link: String) async {
        if let callComposite = try? await createCallComposite() {
            var remoteInfoDisplayName = envConfigSubject.callkitRemoteInfo
            if remoteInfoDisplayName.isEmpty {
                remoteInfoDisplayName = "ACS \(envConfigSubject.selectedMeetingType)"
            }
            let cxHandle = CXHandle(type: .generic, value: getCXHandleName())
            let callKitRemoteInfo = envConfigSubject.enableRemoteInfo ?
            CallKitRemoteInfo(displayName: remoteInfoDisplayName,
                                     handle: cxHandle) : nil
            if envConfigSubject.useDeprecatedLaunch {
                await startCallWithDeprecatedLaunch()
            } else {
                let localOptions = getLocalOptions()
                switch selectedMeetingType {
                case .groupCall:
                    let uuid = UUID(uuidString: link) ?? UUID()
                    callComposite.launch(locator: .groupCall(groupId: uuid),
                                         callKitRemoteInfo: callKitRemoteInfo,
                                         localOptions: localOptions)
                case .teamsMeeting:
                    if !link.isEmpty {
                        callComposite.launch(locator: .teamsMeeting(teamsLink: link),
                                             callKitRemoteInfo: callKitRemoteInfo,
                                             localOptions: localOptions)
                    } else {
                        callComposite.launch(locator: .teamsMeetingId(meetingId:
                                                                        envConfigSubject.teamsMeetingId,
                                                                      meetingPasscode:
                                                                        envConfigSubject.teamsMeetingPasscode),
                                             callKitRemoteInfo: callKitRemoteInfo,
                                             localOptions: localOptions)
                    }
                case.oneToNCall:
                    let ids: [String] = link.split(separator: ",").map {
                        String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    let communicationIdentifiers: [CommunicationIdentifier] =
                    ids.map { createCommunicationIdentifier(fromRawId: $0) }
                    callComposite.launch(participants: communicationIdentifiers,
                                         callKitRemoteInfo: callKitRemoteInfo,
                                         localOptions: localOptions)
                case .roomCall:
                    callComposite.launch(locator: .roomCall(roomId: link),
                                         callKitRemoteInfo: callKitRemoteInfo,
                                         localOptions: localOptions)
                }
            }
        } else {
            showError(for: DemoError.invalidToken.getErrorCode())
            return
        }
    }

    private func getCallKitOptions() -> CallKitOptions {
        let cxHandle = CXHandle(type: .generic, value: getCXHandleName())
        let providerConfig = CXProviderConfiguration()
        providerConfig.supportsVideo = true
        providerConfig.maximumCallGroups = 1
        providerConfig.maximumCallsPerCallGroup = 1
        providerConfig.includesCallsInRecents = true
        providerConfig.supportedHandleTypes = [.phoneNumber, .generic]
        let isCallHoldSupported = envConfigSubject.enableRemoteHold
        let callKitOptions = CallKitOptions(providerConfig: providerConfig,
                                           isCallHoldSupported: isCallHoldSupported,
                                           provideRemoteInfo: incomingCallRemoteInfo,
                                           configureAudioSession: configureAudioSession)
        return callKitOptions
    }

    public func incomingCallRemoteInfo(info: Caller) -> CallKitRemoteInfo {
        let cxHandle = CXHandle(type: .generic, value: "Incoming call")
        var remoteInfoDisplayName = envConfigSubject.callkitRemoteInfo
        if remoteInfoDisplayName.isEmpty {
            remoteInfoDisplayName = info.displayName
        }
        let callKitRemoteInfo = CallKitRemoteInfo(displayName: remoteInfoDisplayName,
                                                               handle: cxHandle)
        return callKitRemoteInfo
    }

    public func configureAudioSession() -> Error? {
        let audioSession = AVAudioSession.sharedInstance()
        var configError: Error?
        do {
            try audioSession.setCategory(.playAndRecord)
        } catch {
            configError = error
        }
        return configError
    }

    private func getCXHandleName() -> String {
        switch envConfigSubject.selectedMeetingType {
        case .groupCall:
            return "Group call"
        case .teamsMeeting:
            return "Teams Metting"
        case .oneToNCall:
            return "Outgoing call"
        case .roomCall:
            return "Rooms call"
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
        case .oneToNCall:
            return participantMRIsTextField.text ?? ""
        case .roomCall:
            return roomCallTextField.text ?? ""
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

    private func showAlert(for message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert,
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

    @objc func onShowExperienceBtnPressed() {
        Task {
            await createCallComposite()?.isHidden = false
        }
    }

    @objc func onRegisterPushBtnPressed() {
        Task {
            await createCallComposite()?
                .registerPushNotifications(
                    deviceRegistrationToken:
                        envConfigSubject.deviceToken!) { result in
                            switch result {
                            case .success:
                                self.showAlert(for: "Register Voip Success")
                            case .failure(let error):
                                self.showAlert(for: "Register Voip fail: \(error.localizedDescription)")
                            }
                }
        }
    }

    @objc func onUnregisterPushBtnPressed() {
        Task {
            await createCallComposite()?
                .unregisterPushNotifications { result in
                            switch result {
                            case .success:
                                self.showAlert(for: "Unregister Voip Success")
                            case .failure(let error):
                                self.showAlert(for: "Unregister Voip fail: \(error.localizedDescription)")
                            }
                }
        }
    }

    @objc func onAcceptCallBtnPressed() {
        self.acceptCallButton.isHidden = true
        self.declineCallButton.isHidden = true
        Task {
            await createCallComposite()?.accept(incomingCallId: incomingCallId,
                                                localOptions: getLocalOptions())
        }
    }

    @objc func onDeclineCallBtnPressed() {
        self.acceptCallButton.isHidden = true
        self.declineCallButton.isHidden = true
        Task {
            await createCallComposite()?.reject(incomingCallId: incomingCallId) { result in
                switch result {
                case .success:
                    self.showAlert(for: "Reject Success")
                case .failure(let error):
                    self.showAlert(for: "Reject fail: \(error.localizedDescription)")
                }
            }
        }
    }

    func onPushNotificationReceived(dictionaryPayload: [AnyHashable: Any]) {
        let pushNotificationInfo = PushNotification(data: dictionaryPayload)
        if envConfigSubject.acsToken.isEmpty {
            self.envConfigSubject.load()
        }
        Task {
            await createCallComposite()?.handlePushNotification(pushNotification: pushNotificationInfo)
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
            teamsMeetingIdTextField.isHidden = true
            teamsMeetingPasscodeTextField.isHidden = true
            participantMRIsTextField.isHidden = true
            roomCallTextField.isHidden = true
        case .teamsMeeting:
            groupCallTextField.isHidden = true
            teamsMeetingTextField.isHidden = false
            teamsMeetingIdTextField.isHidden = false
            teamsMeetingPasscodeTextField.isHidden = false
            participantMRIsTextField.isHidden = true
            roomCallTextField.isHidden = true
        case .roomCall:
            groupCallTextField.isHidden = true
            teamsMeetingTextField.isHidden = true
            teamsMeetingIdTextField.isHidden = true
            teamsMeetingPasscodeTextField.isHidden = true
            participantMRIsTextField.isHidden = true
            roomCallTextField.isHidden = false
        case .oneToNCall:
            groupCallTextField.isHidden = true
            teamsMeetingTextField.isHidden = true
            roomCallTextField.isHidden = true
            participantMRIsTextField.isHidden = false
            teamsMeetingIdTextField.isHidden = true
            teamsMeetingPasscodeTextField.isHidden = true
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
        if (selectedAcsTokenType == .token && acsTokenTextField.text!.isEmpty) ||
            (selectedAcsTokenType == .tokenUrl && acsTokenUrlTextField.text!.isEmpty) ||
            (selectedMeetingType == .groupCall && groupCallTextField.text!.isEmpty) ||
            (selectedMeetingType == .teamsMeeting &&
             (teamsMeetingTextField.text!.isEmpty &&
              (teamsMeetingIdTextField.text!.isEmpty || teamsMeetingPasscodeTextField.text!.isEmpty)
             )) ||
            (selectedMeetingType == .roomCall && roomCallTextField.text!.isEmpty) {
            if (selectedAcsTokenType == .token && acsTokenTextField.text!.isEmpty)
                || (selectedAcsTokenType == .tokenUrl && acsTokenUrlTextField.text!.isEmpty)
                || (selectedMeetingType == .groupCall && groupCallTextField.text!.isEmpty)
                || (selectedMeetingType == .teamsMeeting && teamsMeetingTextField.text!.isEmpty)
                || (selectedMeetingType == .oneToNCall && participantMRIsTextField.text!.isEmpty)
                || (selectedMeetingType == .roomCall && roomCallTextField.text!.isEmpty) {
                return true
            }
        }
        return false
    }

    private func getAudioPermissionStatus() -> AVAudioSession.RecordPermission {
            return AVAudioSession.sharedInstance().recordPermission
    }

    private func setupUI() {
        updateUIBasedOnUserInterfaceStyle()
        let safeArea = view.safeAreaLayoutGuide
#if DEBUG
        // Debug Buttons for Instrumentation to press
        // They shouldn't be visible
        let audioOnlyButton = UIButton(type: .system)
        audioOnlyButton.backgroundColor = UIColor.clear // Making the button transparent
        audioOnlyButton.addTarget(self, action: #selector(toggleAudioOnly), for: .touchUpInside)
        audioOnlyButton.accessibilityIdentifier = AccessibilityId.toggleAudioOnlyModeAccessibilityID.rawValue
        audioOnlyButton.frame = CGRect(x: 0, y: 0, width: 10, height: 10) // Minimal size

        let mockSdkButton = UIButton(type: .system)
        mockSdkButton.backgroundColor = UIColor.clear // Making the button transparent
        mockSdkButton.addTarget(self, action: #selector(toggleMockSdk), for: .touchUpInside)
        mockSdkButton.accessibilityIdentifier = AccessibilityId.useMockCallingSDKHandlerToggleAccessibilityID.rawValue
        mockSdkButton.frame = CGRect(x: 0, y: 0, width: 10, height: 10) // Minimal size

        let debugButtonsStackView = UIStackView(arrangedSubviews: [audioOnlyButton, mockSdkButton])
        debugButtonsStackView.axis = .horizontal
        debugButtonsStackView.distribution = .fillEqually
        debugButtonsStackView.spacing = 4 // Reduced spacing
        debugButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(debugButtonsStackView)

        NSLayoutConstraint.activate([
            debugButtonsStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 8),
            debugButtonsStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            debugButtonsStackView.widthAnchor.constraint(equalToConstant: 24), // Container width
            audioOnlyButton.heightAnchor.constraint(equalToConstant: 10), // Button height
            mockSdkButton.heightAnchor.constraint(equalToConstant: 10) // Button height
        ])
#endif
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
        userIdTextField.placeholder = "User Identifier"
        userIdTextField.text = envConfigSubject.userId
        userIdTextField.translatesAutoresizingMaskIntoConstraints = false
        userIdTextField.delegate = self
        userIdTextField.borderStyle = .roundedRect
        userIdTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

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
        teamsMeetingIdTextField = UITextField()
        teamsMeetingIdTextField.placeholder = "Teams Meeting Id"
        teamsMeetingIdTextField.text = envConfigSubject.teamsMeetingId
        teamsMeetingIdTextField.delegate = self
        teamsMeetingIdTextField.sizeToFit()
        teamsMeetingIdTextField.translatesAutoresizingMaskIntoConstraints = false
        teamsMeetingIdTextField.borderStyle = .roundedRect
        teamsMeetingIdTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        teamsMeetingPasscodeTextField = UITextField()
        teamsMeetingPasscodeTextField.placeholder = "Teams Meeting Passcode"
        teamsMeetingPasscodeTextField.text = envConfigSubject.teamsMeetingPasscode
        teamsMeetingPasscodeTextField.delegate = self
        teamsMeetingPasscodeTextField.sizeToFit()
        teamsMeetingPasscodeTextField.translatesAutoresizingMaskIntoConstraints = false
        teamsMeetingPasscodeTextField.borderStyle = .roundedRect
        teamsMeetingPasscodeTextField.addTarget(
            self, action: #selector(textFieldEditingDidChange), for: .editingChanged)
        participantMRIsTextField = UITextField()
        participantMRIsTextField.placeholder = "Partiicpant MRIs (, separated)"
        participantMRIsTextField.text = envConfigSubject.participantMRIs
        participantMRIsTextField.delegate = self
        participantMRIsTextField.sizeToFit()
        participantMRIsTextField.translatesAutoresizingMaskIntoConstraints = false
        participantMRIsTextField.borderStyle = .roundedRect
        participantMRIsTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        roomCallTextField = UITextField()
        roomCallTextField.placeholder = "Room Id"
        roomCallTextField.text = envConfigSubject.roomId
        roomCallTextField.delegate = self
        roomCallTextField.sizeToFit()
        roomCallTextField.translatesAutoresizingMaskIntoConstraints = false
        roomCallTextField.borderStyle = .roundedRect
        roomCallTextField.addTarget(self, action: #selector(textFieldEditingDidChange), for: .editingChanged)

        meetingTypeSegmentedControl = UISegmentedControl(items: ["Group Call", "Teams Meeting", "1:N", "Room Call"])
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

        showExperienceButton = UIButton()
        showExperienceButton.backgroundColor = .systemBlue
        showExperienceButton.setTitleColor(UIColor.white, for: .normal)
        showExperienceButton.setTitleColor(UIColor.systemGray6, for: .disabled)
        showExperienceButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                                   left: LayoutConstants.buttonHorizontalInset,
                                                                   bottom: LayoutConstants.buttonVerticalInset,
                                                                   right: LayoutConstants.buttonHorizontalInset)
        showExperienceButton.layer.cornerRadius = 8
        showExperienceButton.setTitle("Show", for: .normal)
        showExperienceButton.sizeToFit()
        showExperienceButton.translatesAutoresizingMaskIntoConstraints = false
        showExperienceButton.addTarget(self, action: #selector(onShowExperienceBtnPressed), for: .touchUpInside)
        showExperienceButton.accessibilityLabel = AccessibilityId.showExperienceAccessibilityID.rawValue

        registerPushButton = UIButton()
        registerPushButton.backgroundColor = .systemBlue
        registerPushButton.setTitleColor(UIColor.white, for: .normal)
        registerPushButton.setTitleColor(UIColor.systemGray6, for: .disabled)
        registerPushButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                                   left: LayoutConstants.buttonHorizontalInset,
                                                                   bottom: LayoutConstants.buttonVerticalInset,
                                                                   right: LayoutConstants.buttonHorizontalInset)
        registerPushButton.layer.cornerRadius = 8
        registerPushButton.setTitle("Register push", for: .normal)
        registerPushButton.sizeToFit()
        registerPushButton.translatesAutoresizingMaskIntoConstraints = false
        registerPushButton.addTarget(self, action: #selector(onRegisterPushBtnPressed), for: .touchUpInside)
        registerPushButton.accessibilityLabel = AccessibilityId.registerPushAccessibilityID.rawValue

        unregisterPushButton = UIButton()
        unregisterPushButton.backgroundColor = .systemBlue
        unregisterPushButton.setTitleColor(UIColor.white, for: .normal)
        unregisterPushButton.setTitleColor(UIColor.systemGray6, for: .disabled)
        unregisterPushButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                                   left: LayoutConstants.buttonHorizontalInset,
                                                                   bottom: LayoutConstants.buttonVerticalInset,
                                                                   right: LayoutConstants.buttonHorizontalInset)
        unregisterPushButton.layer.cornerRadius = 8
        unregisterPushButton.setTitle("Unregister push", for: .normal)
        unregisterPushButton.sizeToFit()
        unregisterPushButton.translatesAutoresizingMaskIntoConstraints = false
        unregisterPushButton.addTarget(self, action: #selector(onUnregisterPushBtnPressed), for: .touchUpInside)
        unregisterPushButton.accessibilityLabel = AccessibilityId.unregisterPushAccessibilityID.rawValue

        acceptCallButton = UIButton()
        acceptCallButton.backgroundColor = .systemBlue
        acceptCallButton.setTitleColor(UIColor.white, for: .normal)
        acceptCallButton.setTitleColor(UIColor.systemGray6, for: .disabled)
        acceptCallButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                               left: LayoutConstants.buttonHorizontalInset,
                                                               bottom: LayoutConstants.buttonVerticalInset,
                                                               right: LayoutConstants.buttonHorizontalInset)
        acceptCallButton.layer.cornerRadius = 8
        acceptCallButton.setTitle("Accept", for: .normal)
        acceptCallButton.sizeToFit()
        acceptCallButton.translatesAutoresizingMaskIntoConstraints = false
        acceptCallButton.addTarget(self, action: #selector(onAcceptCallBtnPressed), for: .touchUpInside)
        acceptCallButton.accessibilityLabel = AccessibilityId.acceptCallAccessibilityID.rawValue

        declineCallButton = UIButton()
        declineCallButton.backgroundColor = .systemBlue
        declineCallButton.setTitleColor(UIColor.white, for: .normal)
        declineCallButton.setTitleColor(UIColor.systemGray6, for: .disabled)
        declineCallButton.contentEdgeInsets = UIEdgeInsets.init(top: LayoutConstants.buttonVerticalInset,
                                                               left: LayoutConstants.buttonHorizontalInset,
                                                               bottom: LayoutConstants.buttonVerticalInset,
                                                               right: LayoutConstants.buttonHorizontalInset)
        declineCallButton.layer.cornerRadius = 8
        declineCallButton.setTitle("Reject", for: .normal)
        declineCallButton.sizeToFit()
        declineCallButton.translatesAutoresizingMaskIntoConstraints = false
        declineCallButton.addTarget(self, action: #selector(onDeclineCallBtnPressed), for: .touchUpInside)
        declineCallButton.accessibilityLabel = AccessibilityId.declineCallAccessibilityID.rawValue

        callStateLabel = UILabel()
        callStateLabel.text = "State"
        callStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(callStateLabel)
        callStateLabelConstraint = callStateLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor,
                                                                          constant: LayoutConstants.verticalSpacing)
        callStateLabelConstraint.isActive = true
        callStateLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        callStateLabel.centerYAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10).isActive = true

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

        let startCallButtonHSpacer1 = UIView()
        startCallButtonHSpacer1.translatesAutoresizingMaskIntoConstraints = false
        startCallButtonHSpacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let startCallButtonHSpacer2 = UIView()
        startCallButtonHSpacer2.translatesAutoresizingMaskIntoConstraints = false
        startCallButtonHSpacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let startCallButtonHStack = UIStackView(arrangedSubviews: [startCallButtonHSpacer1,
                                                                  startExperienceButton,
                                                                  startCallButtonHSpacer2])
        startCallButtonHStack.axis = .horizontal
        startCallButtonHStack.alignment = .fill
        startCallButtonHStack.distribution = .fill
        startCallButtonHStack.translatesAutoresizingMaskIntoConstraints = false

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

        let showButtonHSpacer1 = UIView()
        showButtonHSpacer1.translatesAutoresizingMaskIntoConstraints = false
        showButtonHSpacer1.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let showButtonHSpacer2 = UIView()
        showButtonHSpacer2.translatesAutoresizingMaskIntoConstraints = false
        showButtonHSpacer2.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let showButtonHStack = UIStackView(arrangedSubviews: [showButtonHSpacer1,
                                                               showExperienceButton,
                                                               showButtonHSpacer2])
        showButtonHStack.axis = .horizontal
        showButtonHStack.alignment = .fill
        showButtonHStack.distribution = .fill
        showButtonHStack.translatesAutoresizingMaskIntoConstraints = false

        let spaceView1 = UIView()
        spaceView1.translatesAutoresizingMaskIntoConstraints = false
        spaceView1.heightAnchor.constraint(equalToConstant: 0).isActive = true

        let registerUnregisterHStack = UIStackView(arrangedSubviews:
                                                    [registerPushButton, unregisterPushButton])
        registerUnregisterHStack.axis = .horizontal
        registerUnregisterHStack.distribution = .fillEqually // Adjust distribution as needed
        registerUnregisterHStack.spacing = 8

        let acceptDeclineHStack = UIStackView(arrangedSubviews:
                                                    [acceptCallButton, declineCallButton])
        acceptDeclineHStack.axis = .horizontal
        acceptDeclineHStack.distribution = .fillEqually // Adjust distribution as needed
        acceptDeclineHStack.spacing = 8

        stackView = UIStackView(arrangedSubviews: [spaceView1, acsTokenTypeSegmentedControl,
                                                   acsTokenUrlTextField,
                                                   acsTokenTextField,
                                                   displayNameTextField,
                                                   userIdTextField,
                                                   meetingTypeSegmentedControl,
                                                   groupCallTextField,
                                                   teamsMeetingTextField,
                                                   teamsMeetingIdTextField,
                                                   teamsMeetingPasscodeTextField,
                                                   participantMRIsTextField,
                                                   roomCallTextField,
                                                   settingsButtonHStack,
                                                   showHistoryButtonHStack,
                                                   startButtonHStack,
                                                   showButtonHStack,
                                                   registerUnregisterHStack,
                                                   acceptDeclineHStack])
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
        showButtonHSpacer2.widthAnchor.constraint(equalTo: showButtonHSpacer1.widthAnchor).isActive = true

        updateAcsTokenTypeFields()
        updateMeetingTypeFields()
        startExperienceButton.isEnabled = !isStartExperienceDisabled
        updateStartExperieceButton()
        self.acceptCallButton.isHidden = true
        self.declineCallButton.isHidden = true
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

    @objc func toggleAudioOnly() {
        envConfigSubject.audioOnly = !envConfigSubject.audioOnly
    }

    @objc func toggleMockSdk() {
        envConfigSubject.useMockCallingSDKHandler = !envConfigSubject.useMockCallingSDKHandler
    }
}

extension CallingDemoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

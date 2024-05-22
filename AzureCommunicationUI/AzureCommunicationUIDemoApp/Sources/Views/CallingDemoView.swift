//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationCommon
import AVFoundation
import CallKit
#if DEBUG
@testable import AzureCommunicationUICalling
#else
import AzureCommunicationUICalling
#endif
struct CallingDemoView: View {
    @State var isAlertDisplayed = false
    @State var isSettingsDisplayed = false
    @State var isStartExperienceLoading = false
    @State var exitCompositeExecuted = false
    @State var isIncomingCall = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    @State var callState: String = ""
    @State var issue: CallCompositeUserReportedIssue?
    @State var issueUrl: String = ""
    @ObservedObject var envConfigSubject: EnvConfigSubject
    @ObservedObject var callingViewModel: CallingDemoViewModel
    @State var incomingCallId = ""

    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10
    /* <ROOMS_SUPPORT> */
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let roomRoleChoices: [String] = ["Presenter", "Attendee"]
    /* </ROOMS_SUPPORT> */
#if DEBUG
    var callingSDKWrapperMock: UITestCallingSDKWrapper?
#endif
    var body: some View {
        VStack {
#if DEBUG
            // This HStack is for testing toggles.
            // Adjusted to make buttons invisible but still accessible for automation.
            HStack {
                Button("AudioOnly") {
                    envConfigSubject.audioOnly = !envConfigSubject.audioOnly
                }
                .frame(width: 0, height: 0)
                .accessibilityIdentifier(AccessibilityId.toggleAudioOnlyModeAccessibilityID.rawValue)
                Button("MockSdk") {
                    envConfigSubject.useMockCallingSDKHandler = !envConfigSubject.useMockCallingSDKHandler
                }
                .frame(width: 0, height: 0)
                .accessibilityIdentifier(AccessibilityId.useMockCallingSDKHandlerToggleAccessibilityID.rawValue)
            }
#endif
            Text("UI Library - SwiftUI Sample")
            Spacer()
            acsTokenSelector
            displayNameTextField
            meetingSelector

            Group {
                /* <ROOMS_SUPPORT> */
                if envConfigSubject.selectedMeetingType == .roomCall {
                    roomRoleSelector
                } else {
                    roomRoleSelector.hidden()
                }
                /* </ROOMS_SUPPORT> */
                settingButton
                showCallHistoryButton
                startExperienceButton
                showExperienceButton
                HStack {
                    registerPushNotificationButton
                    unregisterPushNotificationButton
                }
                if isIncomingCall {
                    HStack {
                        acceptCallButton
                        declineCallButton
                    }
                }
                Text(callState)
                Text(issue?.userMessage ?? "--")
                .accessibilityIdentifier(AccessibilityId.userReportedIssueAccessibilityID.rawValue)
                if !issueUrl.isEmpty {
                    Link("Ticket Link", destination: URL(string: issueUrl)!)
                }
            }
            Spacer()
        }
        .padding()
        .alert(isPresented: $isAlertDisplayed) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton:
                        .default(Text("Dismiss"), action: {
                            isAlertDisplayed = false
                }))
        }
        .sheet(isPresented: $isSettingsDisplayed) {
            SettingsView(envConfigSubject: envConfigSubject)
        }
    }

    var acsTokenSelector: some View {
        Group {
            Picker("Token Type", selection: $envConfigSubject.selectedAcsTokenType) {
                Text("Token URL").tag(ACSTokenType.tokenUrl)
                Text("Token").tag(ACSTokenType.token)
            }.pickerStyle(.segmented)
            switch envConfigSubject.selectedAcsTokenType {
            case .tokenUrl:
                TextField("ACS Token URL", text: $envConfigSubject.acsTokenUrl)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
            case .token:
                TextField("ACS Token", text:
                            !envConfigSubject.useExpiredToken ?
                          $envConfigSubject.acsToken : $envConfigSubject.expiredAcsToken)
                    .modifier(TextFieldClearButton(text: $envConfigSubject.acsToken))
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }

    var displayNameTextField: some View {
        TextField("Display Name", text: $envConfigSubject.displayName)
            .disableAutocorrection(true)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .textFieldStyle(.roundedBorder)
    }

    var meetingSelector: some View {
        Group {
            Picker("Call Type", selection: $envConfigSubject.selectedMeetingType) {
                Text("Group Call").tag(MeetingType.groupCall)
                Text("Teams Meeting").tag(MeetingType.teamsMeeting)
                Text("1:N Call").tag(MeetingType.oneToNCall)
                /* <ROOMS_SUPPORT> */ Text("Room Call").tag(MeetingType.roomCall) /* </ROOMS_SUPPORT> */
            }.pickerStyle(.segmented)
            switch envConfigSubject.selectedMeetingType {
            case .groupCall:
                TextField(
                    "Group Call Id",
                    text: $envConfigSubject.groupCallId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            case .teamsMeeting:
                TextField(
                    "Team Meeting",
                    text: $envConfigSubject.teamsMeetingLink)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            case .oneToNCall:
                TextField(
                    "participant MRIs(, separated)",
                    text: $envConfigSubject.participantMRIs)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                /* <ROOMS_SUPPORT> */
            case .roomCall:
                TextField(
                    "Room Id",
                    text: $envConfigSubject.roomId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                /* </ROOMS_SUPPORT> */
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }

    /* <ROOMS_SUPPORT> */
    var roomRoleSelector: some View {

        Section {
            Picker("Room Role Type", selection: $envConfigSubject.selectedRoomRoleType) {
                Text("Presenter").tag(RoomRoleType.presenter)
                Text("Attendee").tag(RoomRoleType.attendee)
            }.pickerStyle(.segmented)
        }
    }
    /* </ROOMS_SUPPORT> */

    var settingButton: some View {
        Button("Settings") {
            isSettingsDisplayed = true
        }
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)
    }

    var startExperienceButton: some View {
        Button("Start Experience") {
            isStartExperienceLoading = true
            Task { @MainActor in
                if getAudioPermissionStatus() == .denied && envConfigSubject.skipSetupScreen {
                    showError(for: CallCompositeErrorCode.microphonePermissionNotGranted)
                    isStartExperienceLoading = false
                    return
                }
                await startCallComposite()
                isStartExperienceLoading = false
            }
        }
        .buttonStyle(DemoButtonStyle())
        .disabled(isStartExperienceDisabled || isStartExperienceLoading)
        .accessibility(identifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
    }

    var showExperienceButton: some View {
        Button("Show") {
            showCallComposite()
        }
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.showExperienceAccessibilityID.rawValue)
    }

    var registerPushNotificationButton: some View {
        Button("Register push") {
            registerPushNotification()
        }
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.registerPushAccessibilityID.rawValue)
    }

    var unregisterPushNotificationButton: some View {
        Button("Unregister push") {
            unregisterPushNotification()
        }
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.unregisterPushAccessibilityID.rawValue)
    }

    var showCallHistoryButton: some View {
        Button("Show call history") {
            alertTitle = callingViewModel.callHistoryTitle
            alertMessage = callingViewModel.callHistoryMessage
            isAlertDisplayed = true
        }
        .buttonStyle(DemoButtonStyle())
    }

    var acceptCallButton: some View {
        Button("Accept") {
            accept()
        }
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.acceptCallAccessibilityID.rawValue)
    }

    var declineCallButton: some View {
        Button("Decline") {
            decline()
        }
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.declineCallAccessibilityID.rawValue)
    }

    var isStartExperienceDisabled: Bool {
        let acsToken = envConfigSubject.useExpiredToken ? envConfigSubject.expiredAcsToken : envConfigSubject.acsToken
        if (envConfigSubject.selectedAcsTokenType == .token && acsToken.isEmpty)
            || envConfigSubject.selectedAcsTokenType == .tokenUrl && envConfigSubject.acsTokenUrl.isEmpty {
            return true
        }

        if (envConfigSubject.selectedMeetingType == .groupCall && envConfigSubject.groupCallId.isEmpty)
            || envConfigSubject.selectedMeetingType == .teamsMeeting && envConfigSubject.teamsMeetingLink.isEmpty {
            return true
        }

        return false
    }
}

extension CallingDemoView {
    func showCallComposite() {
        callingViewModel.callComposite?.isHidden = false
    }

    func registerPushNotification() {

    }

    func unregisterPushNotification() {

    }

    func accept() {

    }

    func decline() {

    }

    fileprivate func relaunchComposite() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task { @MainActor in
                if getAudioPermissionStatus() == .denied && envConfigSubject.skipSetupScreen {
                    showError(for: CallCompositeErrorCode.microphonePermissionNotGranted)
                    isStartExperienceLoading = false
                    return
                }
                await startCallComposite()
                isStartExperienceLoading = false
            }
        }
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
        let callScreenOptions = CallScreenOptions(controlBarOptions: barOptions)
        if !envConfigSubject.localeIdentifier.isEmpty {
            let locale = Locale(identifier: envConfigSubject.localeIdentifier)
            localizationConfig = LocalizationOptions(locale: locale,
                                                           layoutDirection: layoutDirection)
        } else if !envConfigSubject.locale.identifier.isEmpty {
            localizationConfig = LocalizationOptions(
                locale: envConfigSubject.locale,
                layoutDirection: layoutDirection)
        }

        let setupViewOrientation = envConfigSubject.setupViewOrientation
        let callingViewOrientation = envConfigSubject.callingViewOrientation
        let callKitOptions = $envConfigSubject.enableCallKit.wrappedValue ? getCallKitOptions() : nil

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
            callKitOptions: callKitOptions) :
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
            disableInternalPushForIncomingCall: envConfigSubject.disableInternalPushForIncomingCall)

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
            onError(error,
                    callComposite: composite)
        }

        let onPipChangedHandler: (Bool) -> Void = { isPictureInPicture in
            print("::::CallingDemoView:onPipChangedHandler: ", isPictureInPicture)
        }

        let onUserReportedIssueHandler: (CallCompositeUserReportedIssue) -> Void = { issue in
            DispatchQueue.main.schedule {
                self.issue = issue
            }
            sendSupportEventToServer(event: issue) { success, result in
                if success {
                    self.issueUrl = result
                } else {
                    self.issueUrl = ""
                }
            }
        }

        let onCallStateChangedHandler: (CallState) -> Void = { [weak callComposite] callStateEvent in
            guard let composite = callComposite else {
                return
            }
            onCallStateChanged(callStateEvent,
                    callComposite: composite)
        }
        let onDismissedHandler: (CallCompositeDismissed) -> Void = { [] _ in
            if envConfigSubject.useRelaunchOnDismissedToggle && exitCompositeExecuted {
                relaunchComposite()
            }
        }

        exitCompositeExecuted = false
        if !envConfigSubject.exitCompositeAfterDuration.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() +
                                          Float64(envConfigSubject.exitCompositeAfterDuration)!
            ) { [weak callComposite] in
                exitCompositeExecuted = true
                callComposite?.dismiss()
            }
        }

        let callKitCallAccepted: (String) -> Void = { [weak callComposite] callId in
            callComposite?.launch(callIdAcceptedFromCallKit: callId, localOptions: getLocalOptions())
        }

        let onIncomingCall: (IncomingCall) -> Void = { [] incomingCall in
            incomingCallId = incomingCall.callId
            isIncomingCall = true
        }

        let onIncomingCallCancelled: (IncomingCallCancelled) -> Void = { [] _ in
            isIncomingCall = false
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
        /* <ROOMS_SUPPORT> */
        let roomRole = envConfigSubject.selectedRoomRoleType
        var roomRoleData: ParticipantRole?
        if envConfigSubject.selectedMeetingType == .roomCall {
            if roomRole == .presenter {
                roomRoleData = ParticipantRole.presenter
            } else if roomRole == .attendee {
                roomRoleData = ParticipantRole.attendee
            }
        }
        /* </ROOMS_SUPPORT> */
        let setupScreenViewData = SetupScreenViewData(title: envConfigSubject.navigationTitle,
                                                          subtitle: envConfigSubject.navigationSubtitle)
        return LocalOptions(participantViewData: participantViewData,
                                        setupScreenViewData: setupScreenViewData,
                                        cameraOn: envConfigSubject.cameraOn,
                                        microphoneOn: envConfigSubject.microphoneOn,
                                        skipSetupScreen: envConfigSubject.skipSetupScreen,
                                        /* <ROOMS_SUPPORT> */
                                         audioVideoMode: envConfigSubject.audioOnly ? .audioOnly : .audioAndVideo,
                                         roleHint: roomRoleData
                                        /* <|ROOMS_SUPPORT>
                                        audioVideoMode: envConfigSubject.audioOnly ? .audioOnly : .audioAndVideo
                                        </ROOMS_SUPPORT> */
        )
    }

    func startCallWithDeprecatedLaunch() async {
        if let credential = try? await getTokenCredential(),
           let callComposite = try? await createCallComposite() {
            let link = getMeetingLink()
            var localOptions = getLocalOptions()
            switch envConfigSubject.selectedMeetingType {
            case .groupCall:
                let uuid = UUID(uuidString: link) ?? UUID()
                if envConfigSubject.displayName.isEmpty {
                    callComposite.launch(remoteOptions: RemoteOptions(for: .groupCall(groupId: uuid),
                                                                      credential: credential),
                                         localOptions: localOptions)
                } else {
                    callComposite.launch(remoteOptions: RemoteOptions(for: .groupCall(groupId: uuid),
                                                                      credential: credential,
                                                                      displayName: envConfigSubject.displayName),
                                         localOptions: localOptions)
                }
            case .teamsMeeting:
                if envConfigSubject.displayName.isEmpty {
                    callComposite.launch(remoteOptions: RemoteOptions(for: .teamsMeeting(teamsLink: link),
                                                                      credential: credential),
                                         localOptions: localOptions)
                } else {
                    callComposite.launch(remoteOptions: RemoteOptions(for: .teamsMeeting(teamsLink: link),
                                                                      credential: credential,
                                                                      displayName: envConfigSubject.displayName),
                                         localOptions: localOptions)
                }
            case .oneToNCall:
                let ids: [String] = link.split(separator: ",").map {
                    String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                let communicationIdentifiers: [CommunicationIdentifier] =
                ids.map { createCommunicationIdentifier(fromRawId: $0) }
                callComposite.launch(participants: communicationIdentifiers,
                                     localOptions: localOptions)
                /* <ROOMS_SUPPORT> */
            case .roomCall:
                if envConfigSubject.displayName.isEmpty {
                    callComposite.launch(remoteOptions:
                                            RemoteOptions(for: .roomCall(roomId: link),
                                                          credential: credential),
                                         localOptions: localOptions)
                } else {
                    callComposite.launch(
                        remoteOptions: RemoteOptions(for:
                                .roomCall(roomId: link),
                                                     credential: credential,
                                                     displayName: envConfigSubject.displayName),
                        localOptions: localOptions)
                }
                /* </ROOMS_SUPPORT> */
            }
        }
    }

    func startCallComposite() async {
        let link = getMeetingLink()
        if let callComposite = try? await createCallComposite() {
            var localOptions = getLocalOptions()
            var remoteInfoDisplayName = envConfigSubject.callkitRemoteInfo
            if remoteInfoDisplayName.isEmpty {
                remoteInfoDisplayName = "ACS \(envConfigSubject.selectedMeetingType)"
            }
            let cxHandle = CXHandle(type: .generic, value: getCXHandleName())
            let callKitRemoteInfo = $envConfigSubject.enableRemoteInfo.wrappedValue ?
            CallKitRemoteInfo(displayName: remoteInfoDisplayName,
                                     handle: cxHandle) : nil
            if envConfigSubject.useDeprecatedLaunch {
                try? await startCallWithDeprecatedLaunch()
            } else {
                switch envConfigSubject.selectedMeetingType {
                case .groupCall:
                    let uuid = UUID(uuidString: link) ?? UUID()
                    callComposite.launch(locator: .groupCall(groupId: uuid),
                                         callKitRemoteInfo: callKitRemoteInfo,
                                         localOptions: localOptions)
                case .teamsMeeting:
                    callComposite.launch(locator: .teamsMeeting(teamsLink: link),
                                         callKitRemoteInfo: callKitRemoteInfo,
                                         localOptions: localOptions)
                case .oneToNCall:
                    let ids: [String] = link.split(separator: ",").map {
                        String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    let communicationIdentifiers: [CommunicationIdentifier] =
                    ids.map { createCommunicationIdentifier(fromRawId: $0) }
                    callComposite.launch(participants: communicationIdentifiers,
                                         callKitRemoteInfo: callKitRemoteInfo,
                                         localOptions: localOptions)
                    /* <ROOMS_SUPPORT> */
                case .roomCall:
                    callComposite.launch(
                        locator: .roomCall(roomId: link),
                        callKitRemoteInfo: callKitRemoteInfo,
                        localOptions: localOptions)
                    /* </ROOMS_SUPPORT> */
                }
            }
            callingViewModel.callComposite = callComposite
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
        let isCallHoldSupported = $envConfigSubject.enableRemoteHold.wrappedValue
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
        switch envConfigSubject.selectedAcsTokenType {
        case .token:
            let acsToken = envConfigSubject.useExpiredToken ?
                           envConfigSubject.expiredAcsToken : envConfigSubject.acsToken
            if let communicationTokenCredential = try? CommunicationTokenCredential(token: acsToken) {
                return communicationTokenCredential
            } else {
                throw DemoError.invalidToken
            }
        case .tokenUrl:
            if let url = URL(string: envConfigSubject.acsTokenUrl) {
                let tokenRefresher = AuthenticationHelper.getCommunicationToken(tokenUrl: url,
                                                                                aadToken: envConfigSubject.aadToken)
                let initialToken = await AuthenticationHelper.fetchInitialToken(with: tokenRefresher)
                let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: initialToken,
                                                                                        refreshProactively: true,
                                                                                        tokenRefresher: tokenRefresher)
                if let credential = try? CommunicationTokenCredential(withOptions: communicationTokenRefreshOptions) {
                    return credential
                }
            }
            throw DemoError.invalidToken
        }
    }

    private func getMeetingLink() -> String {
        switch envConfigSubject.selectedMeetingType {
        case .groupCall:
            return envConfigSubject.groupCallId
        case .teamsMeeting:
            return envConfigSubject.teamsMeetingLink
        case .oneToNCall:
            return envConfigSubject.participantMRIs
        /* <ROOMS_SUPPORT> */
        case .roomCall:
            return envConfigSubject.roomId
        /* </ROOMS_SUPPORT> */
        }
    }

    private func showError(for errorCode: String) {
        switch errorCode {
        case CallCompositeErrorCode.tokenExpired:
            alertMessage = "Token is invalid"
        case CallCompositeErrorCode.microphonePermissionNotGranted:
            alertMessage = "Microphone Permission is denied"
        case CallCompositeErrorCode.networkConnectionNotAvailable:
            alertMessage = "Internet error"
        default:
            alertMessage = "Unknown error"
        }
        alertTitle = "Error"
        isAlertDisplayed = true
    }

    private func getAudioPermissionStatus() -> AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }

    private func onError(_ error: CallCompositeError, callComposite: CallComposite) {
        print("::::CallingDemoView::getEventsHandler::onError \(error)")
        print("::::CallingDemoView error.code \(error.code)")
        callingViewModel.callHistory.last?.callIds.forEach { print("::::CallingDemoView call id \($0)") }
        showError(for: error.code)
    }

    private func onCallStateChanged(_ callState: CallState, callComposite: CallComposite) {
        print("::::CallingDemoView::getEventsHandler::onCallStateChanged \(callState.requestString)")
        self.callState = callState.requestString
    }

    private func onRemoteParticipantJoined(to callComposite: CallComposite, identifiers: [CommunicationIdentifier]) {
        print("::::CallingDemoView::getEventsHandler::onRemoteParticipantJoined \(identifiers)")
        guard envConfigSubject.useCustomRemoteParticipantViewData else {
            return
        }

        RemoteParticipantAvatarHelper.onRemoteParticipantJoined(to: callComposite,
                                                                identifiers: identifiers)
    }
}

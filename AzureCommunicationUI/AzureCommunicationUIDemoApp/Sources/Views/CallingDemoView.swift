//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import Foundation
import AzureCommunicationCommon
import AVFoundation
import CallKit
import OSLog
#if DEBUG
@testable import AzureCommunicationUICalling
#else
import AzureCommunicationUICalling
#endif
struct CallingDemoView: View {
    @State var isAlertDisplayed: Bool = false
    @State var isSettingsDisplayed: Bool = false
    @State var isStartExperienceLoading: Bool = false
    @State var exitCompositeExecuted: Bool = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    @State var callState: String = ""
    @State var isPushNotificationAvailable: Bool = false
    @ObservedObject var envConfigSubject: EnvConfigSubject
    @ObservedObject var callingViewModel: CallingDemoViewModel
    @State static var callComposite: CallComposite?
    // swiftlint:disable explicit_type_interface
    let userDefault = UserDefaults.standard
    // swiftlint:enable explicit_type_interface
    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let roomRoleChoices: [String] = ["Presenter", "Attendee"]
#if DEBUG
    var callingSDKWrapperMock: UITestCallingSDKWrapper?
#endif

    var body: some View {
        VStack {
            Text("UI Library - SwiftUI Sample")
            Spacer()
            acsTokenSelector
            displayNameTextField
            meetingSelector
            if envConfigSubject.selectedMeetingType == .roomCall {
                roomRoleSelector
            } else {
                roomRoleSelector.hidden()
            }
            Group {
                registerButton
                settingButton
                showCallHistoryButton
                startExperienceButton
                disposeButton
                showExperienceButton
                Text(callState)
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
                Text("Room Call").tag(MeetingType.roomCall)
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
                    "One To N Calling",
                    text: $envConfigSubject.participantIds)
            case .roomCall:
                TextField(
                    "Room Id",
                    text: $envConfigSubject.roomId)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }
    var roomRoleSelector: some View {

        Section {
            Picker("Room Role Type", selection: $envConfigSubject.selectedRoomRoleType) {
                Text("Presenter").tag(RoomRoleType.presenter)
                Text("Attendee").tag(RoomRoleType.attendee)
            }.pickerStyle(.segmented)
        }
    }

    var settingButton: some View {
        Button("Settings") {
            isSettingsDisplayed = true
        }
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)
    }

    var disposeButton: some View {
        Button("Dispose") {
            self.disposeComposite()
        }
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.disposeButtonAccessibilityID.rawValue)
    }

    var registerButton: some View {
        Button("Register Voip Notification") {
            Task {
                await self.registerForNotification()
            }
        }
        .disabled(isRegisterPushDisabled)
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.registerButtonAccessibilityID.rawValue)
    }

    var handleNotificationButton: some View {
        Button("Handler push notification") {
        }
        .disabled(isStartExperienceDisabled)
        .buttonStyle(DemoButtonStyle())
        .accessibility(identifier: AccessibilityId.registerButtonAccessibilityID.rawValue)
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
        .accessibility(identifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
    }

    var showCallHistoryButton: some View {
        Button("Show call history") {
            alertTitle = callingViewModel.callHistoryTitle
            alertMessage = callingViewModel.callHistoryMessage
            isAlertDisplayed = true
        }
        .buttonStyle(DemoButtonStyle())
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

    var isRegisterPushDisabled: Bool {
        let acsToken = envConfigSubject.acsToken
        if (envConfigSubject.selectedAcsTokenType == .token && acsToken.isEmpty)
            || envConfigSubject.selectedAcsTokenType == .tokenUrl && envConfigSubject.acsTokenUrl.isEmpty {
            return true
        }
        return false
    }
}

extension CallingDemoView {
    fileprivate func relaunchComposite() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task { @MainActor in
                if getAudioPermissionStatus() == .denied && envConfigSubject.skipSetupScreen {
                    showError(for: CallCompositeErrorCode.microphonePermissionNotGranted)
                    isStartExperienceLoading = false
                    return
                }
                print("onExitedHandler: starting composite")
                await startCallComposite()
                isStartExperienceLoading = false
            }
        }
    }

    func showCallComposite() {
        callingViewModel.callComposite?.displayCallCompositeIfWasHidden()
    }

    private func readStringData(key: String) -> String {
        if userDefault.object(forKey: key) == nil {
            return ""
        } else {
            return userDefault.string(forKey: key)!
        }
    }

    func onPushNotificationReceived(dictionaryPayload: [AnyHashable: Any]) {
        let pushNotificationInfo = CallCompositePushNotificationInfo(pushNotificationInfo: dictionaryPayload)
        os_log("calling demo app: onPushNotificationReceived CallingDemoView")
        if envConfigSubject.acsToken.isEmpty {
            os_log("calling demo app: envConfigSubject acs token is empty")
            var data = [String: String]()
            data["name"] = readStringData(key: "DISPLAY_NAME")
            data["acstoken"] = readStringData(key: "ACS_TOKEN")
            self.envConfigSubject.update(from: data)
        }
        if let communicationTokenCredential = try? CommunicationTokenCredential(token: envConfigSubject.acsToken) {
            Task {
                os_log("calling demo app: calling handlePushNotification")
                let displayName = envConfigSubject.displayName.isEmpty ? nil : envConfigSubject.displayName
                let remoteOptions = RemoteOptions(for: pushNotificationInfo,
                                                  credential: communicationTokenCredential,
                                                  displayName: displayName,
                                                  callKitOptions: getCallKitOptions())
                do {
                    try await createCallComposite().handlePushNotification(remoteOptions: remoteOptions)
                } catch {
                    // Handle the error
                    print("Error: \(error)")
                }
            }
        }
    }

    func createCallComposite() -> CallComposite {
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

        let setupViewOrientation = envConfigSubject.setupViewOrientation
        let callingViewOrientation = envConfigSubject.callingViewOrientation
        let callCompositeOptions = CallCompositeOptions(
            theme: envConfigSubject.useCustomColors
            ? CustomColorTheming(envConfigSubject: envConfigSubject)
            : Theming(envConfigSubject: envConfigSubject),
            localization: localizationConfig,
            setupScreenOrientation: setupViewOrientation,
            callingScreenOrientation: callingViewOrientation,
            enableMultitasking: true,
            enableSystemPiPWhenMultitasking: true)
        var callComposite: CallComposite
        #if DEBUG
        let useMockCallingSDKHandler = envConfigSubject.useMockCallingSDKHandler
        callComposite = useMockCallingSDKHandler ?
            CallComposite(withOptions: callCompositeOptions,
                          callingSDKWrapperProtocol: callingSDKWrapperMock)
            : CallComposite(withOptions: callCompositeOptions)
        #else
        callComposite = CallComposite(withOptions: callCompositeOptions)
        #endif
        subscribeToEvents(callComposite: callComposite)
        CallingDemoView.callComposite = callComposite
        return callComposite
    }

    func subscribeToEvents(callComposite: CallComposite) {
        let onRemoteParticipantJoinedHandler: ([CommunicationIdentifier]) -> Void = { [weak callComposite] ids in
            guard let composite = callComposite else {
                return
            }
            self.onRemoteParticipantJoined(to: composite,
                                           identifiers: ids)
        }
        let onPipChangedHandler: (Bool) -> Void = { isInPictureInPicture in
            print("::::CallingDemoView:onPipChangedHandler: ", isInPictureInPicture)
        }
        let onErrorHandler: (CallCompositeError) -> Void = { [weak callComposite] error in
            guard let composite = callComposite else {
                return
            }
            onError(error,
                    callComposite: composite)
        }

        let onCallStateChangedHandler: (CallState) -> Void = { [weak callComposite] callStateEvent in
            guard let composite = callComposite else {
                return
            }
            onCallStateChanged(callStateEvent,
                    callComposite: composite)
        }

        let onDismissedHandler: (CallCompositeDismissed) -> Void = { [] _ in
            // Known issue: every time on exit register for push to receive again
            Task {
                await self.registerForNotification()
            }
            if envConfigSubject.useRelaunchOnDismissedToggle && exitCompositeExecuted {
                relaunchComposite()
            }
            print("::::CallingDemoView ::::onDismissedHandler ")
        }
        let onInomingCall: (CallCompositeIncomingCallInfo) -> Void = { [] _ in
            print("::::CallingDemoView: Incoming Call ::::CallInfo ")
        }
        let onInomingCallEnded: (CallCompositeIncomingCallEndedInfo) -> Void = { [] _ in
            print("::::CallingDemoView: Incoming Call ::::CallEndedInfo")
        }
        callComposite.events.onRemoteParticipantJoined = onRemoteParticipantJoinedHandler
        callComposite.events.onError = onErrorHandler
        callComposite.events.onCallStateChanged = onCallStateChangedHandler
        callComposite.events.onDismissed = onDismissedHandler
        callComposite.events.onIncomingCall = onInomingCall
        callComposite.events.onIncomingCallEnded = onInomingCallEnded
        callComposite.events.onPictureInPictureChanged = onPipChangedHandler
    }

    func startCallComposite() async {
        let callComposite = createCallComposite()
        let link = getMeetingLink()
        exitCompositeExecuted = false
        if !envConfigSubject.exitCompositeAfterDuration.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() +
                                          Float64(envConfigSubject.exitCompositeAfterDuration)!
            ) { [weak callComposite] in
                exitCompositeExecuted = true
                callComposite?.dismiss()
            }
        }

        let renderDisplayName = envConfigSubject.renderedDisplayName.isEmpty ?
                                nil:envConfigSubject.renderedDisplayName
        let participantViewData = ParticipantViewData(avatar: UIImage(named: envConfigSubject.avatarImageName),
                                                      displayName: renderDisplayName)
        let roomRole = envConfigSubject.selectedRoomRoleType
        var roomRoleData: ParticipantRole?
        if envConfigSubject.selectedMeetingType == .roomCall {
            if roomRole == .presenter {
                roomRoleData = ParticipantRole.presenter
            } else if roomRole == .attendee {
                roomRoleData = ParticipantRole.attendee
            }
        }

        let setupScreenViewData = SetupScreenViewData(title: envConfigSubject.navigationTitle,
                                                          subtitle: envConfigSubject.navigationSubtitle)
        let localOptions = LocalOptions(participantViewData: participantViewData,
                                        setupScreenViewData: setupScreenViewData,
                                        roleHint: roomRoleData,
                                        cameraOn: envConfigSubject.cameraOn,
                                        microphoneOn: envConfigSubject.microphoneOn,
                                        skipSetupScreen: envConfigSubject.skipSetupScreen)
        let callKitOptions = getCallKitOptions()
        if let credential = try? await getTokenCredential() {
            switch envConfigSubject.selectedMeetingType {
            case .groupCall:
                let uuid = UUID(uuidString: link) ?? UUID()
                let displayName = envConfigSubject.displayName.isEmpty ? nil : envConfigSubject.displayName

                let remoteOptions = RemoteOptions(for: .groupCall(groupId: uuid),
                                                  credential: credential,
                                                  displayName: displayName,
                                                  callKitOptions: $envConfigSubject.enableCallKit.wrappedValue
                                                  ? callKitOptions : nil)

                callComposite.launch(remoteOptions: remoteOptions, localOptions: localOptions)
            case .teamsMeeting:
                let remoteOptions = RemoteOptions(for: .teamsMeeting(teamsLink: link),
                                                  credential: credential,
                                                  displayName: envConfigSubject.displayName.isEmpty
                                                  ? nil : envConfigSubject.displayName,
                                                  callKitOptions: $envConfigSubject.enableCallKit.wrappedValue
                                                  ? callKitOptions : nil)

                callComposite.launch(remoteOptions: remoteOptions, localOptions: localOptions)
            case .oneToNCall:
                let localOptionsForOneToN = LocalOptions(participantViewData: participantViewData,
                                                setupScreenViewData: setupScreenViewData,
                                                cameraOn: envConfigSubject.cameraOn,
                                                microphoneOn: envConfigSubject.microphoneOn,
                                                skipSetupScreen: envConfigSubject.skipSetupScreen)
                let ids: [String] = link.split(separator: ",").map {
                    String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                let startCallOptions = StartCallOptionsOneToNCall(participants: ids)
                let remoteOptions = RemoteOptions(for: startCallOptions,
                                                  credential: credential,
                                                  displayName: envConfigSubject.displayName.isEmpty
                                                  ? nil : envConfigSubject.displayName,
                                                  callKitOptions: $envConfigSubject.enableCallKit.wrappedValue
                                                  ? callKitOptions : nil)
                callComposite.launch(remoteOptions: remoteOptions,
                                     localOptions: localOptionsForOneToN)
            case .roomCall:
                if envConfigSubject.displayName.isEmpty {
                    callComposite.launch(remoteOptions:
                                            RemoteOptions(for: .roomCall(roomId: link),
                                                          credential: credential,
                                                          callKitOptions: $envConfigSubject.enableCallKit.wrappedValue
                                                          ? callKitOptions : nil),
                                         localOptions: localOptions)
                } else {
                    callComposite.launch(
                        remoteOptions: RemoteOptions(for:
                                .roomCall(roomId: link),
                                                     credential: credential,
                                                     displayName: envConfigSubject.displayName,
                                                     callKitOptions: $envConfigSubject.enableCallKit.wrappedValue
                                                     ? callKitOptions : nil),
                        localOptions: localOptions)
                }
            }
        } else {
            showError(for: DemoError.invalidToken.getErrorCode())
            return
        }
        callingViewModel.callComposite = callComposite
    }

    func disposeComposite() {
        createCallComposite().dispose()
    }

    func registerForNotification() async {
        if let credential = try? await getTokenCredential() {
            let displayName = envConfigSubject.displayName.isEmpty ? nil : envConfigSubject.displayName
            let notificationOptions = CallCompositePushNotificationOptions(
                deviceToken: $envConfigSubject.deviceToken.wrappedValue!,
                credential: credential,
                displayName: displayName,
                callKitOptions: getCallKitOptions())
            writeAnyData(key: "DISPLAY_NAME", value: displayName)
            print("CallingDemoView, registerPushNotification")
            Task {
                do {
                    try await createCallComposite().registerPushNotification(notificationOptions: notificationOptions)
                    showAlert(for: "Register Voip Success")
                } catch {
                    showAlert(for: "Register Voip Failed")
                    print("Error: \(error)")
                }
            }
        }
    }

    private func writeAnyData(key: String, value: Any) {
        userDefault.set(value, forKey: key)
        userDefault.synchronize()
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

    private func getCallKitOptions() -> CallCompositeCallKitOption {
        let cxHandle = CXHandle(type: .generic, value: getMeetingLink())
        let cxProvider = CallCompositeCallKitOption.getDefaultCXProviderConfiguration()
        var remoteInfoDisplayName = envConfigSubject.callkitRemoteInfo
        if remoteInfoDisplayName.isEmpty {
            remoteInfoDisplayName = "ACS \(envConfigSubject.selectedMeetingType)"
        }
        let callKitRemoteInfo = CallCompositeCallKitRemoteInfo(displayName: remoteInfoDisplayName,
                                                               cxHandle: cxHandle)
        let isCallHoldSupported = $envConfigSubject.enableRemoteHold.wrappedValue
        let callKitOptions = CallCompositeCallKitOption(cxProvideConfig: cxProvider,
                                                       isCallHoldSupported: isCallHoldSupported,
                                                       remoteInfo: $envConfigSubject.enableRemoteInfo.wrappedValue
                                                        ? callKitRemoteInfo : nil,
         configureAudioSession: configureAudioSession)
        return callKitOptions
    }

    private func getTokenCredential() async throws -> CommunicationTokenCredential {
        switch envConfigSubject.selectedAcsTokenType {
        case .token:
            let acsToken = envConfigSubject.useExpiredToken ?
                           envConfigSubject.expiredAcsToken : envConfigSubject.acsToken
            // We need to make a service call to get token for user in case application is not running
            // Storing token in shared preferences for demo purpose as this app is not public
            // In production, token should be fetched from server (storing token in pref can be a security issue)
            writeAnyData(key: "ACS_TOKEN", value: acsToken)
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
            return envConfigSubject.participantIds
        case .roomCall:
            return envConfigSubject.roomId
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
        case CallCompositeErrorCode.callDeclined:
            alertMessage = "Call Declined"
        case CallCompositeErrorCode.canNotMakeCall:
            alertMessage = "Not subscribed to receive push"
        default:
            alertMessage = "Unknown error"
        }
        alertTitle = "Error"
        isAlertDisplayed = true
    }

    /// not important to display
    /// if other error is displayed then skip
    private func showAlert(for message: String) {
        if !isAlertDisplayed {
            alertMessage = message
            alertTitle = "Alert"
            isAlertDisplayed = true
        }
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

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
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
    @State private var isNewViewPresented = false
    @ObservedObject var envConfigSubject: EnvConfigSubject
    @ObservedObject var callingViewModel: CallingDemoViewModel
    @State var incomingCallId = ""
    /* <TIMER_TITLE_FEATURE> */
    @State var headerViewData: CallScreenHeaderViewData?
    /* </TIMER_TITLE_FEATURE> */
    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10
    var callComposite = CallComposite()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
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
                .frame(width: 1, height: 1)
                .accessibilityIdentifier(AccessibilityId.toggleAudioOnlyModeAccessibilityID.rawValue)
                Button("MockSdk") {
                    envConfigSubject.useMockCallingSDKHandler = !envConfigSubject.useMockCallingSDKHandler
                }
                .frame(width: 1, height: 1)
                .accessibilityIdentifier(AccessibilityId.useMockCallingSDKHandlerToggleAccessibilityID.rawValue)
            }
#endif
            Text("UI Library - SwiftUI Sample")
            Spacer()
            acsTokenSelector
            displayNameTextField
            userIdTextField
            meetingSelector

            Group {
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
                primaryButton: .default(Text("Copy")) {
                    UIPasteboard.general.string = alertMessage
                },
                secondaryButton:
                        .default(Text("Dismiss"), action: {
                            isAlertDisplayed = false
                }))
        }
        .sheet(isPresented: $isSettingsDisplayed) {
            SettingsView(envConfigSubject: envConfigSubject)
        }
        .fullScreenCover(isPresented: $isNewViewPresented) {
            CustomDemoView()
        }
        #if DEBUG
        .onAppear(perform: {
            // Dev helper to jump through to mocked experiences
            Task {
                if EnvConfig.skipTo.value() == "MockCallScreen" {
                    envConfigSubject.useMockCallingSDKHandler = true
                    envConfigSubject.skipSetupScreen = true
                    await startCallComposite()
                } else if EnvConfig.skipTo.value() == "MockSetupScreen" {
                    envConfigSubject.useMockCallingSDKHandler = true
                    envConfigSubject.skipSetupScreen = false
                    await startCallComposite()
                } else if EnvConfig.skipTo.value() == "TeamsCallScreen" {
                    envConfigSubject.enableCallKit = false
                    envConfigSubject.selectedMeetingType = .teamsMeeting
                    envConfigSubject.skipSetupScreen = true
                    await startCallComposite()
                } else if EnvConfig.skipTo.value() == "TeamsSetupScreen" {
                    envConfigSubject.enableCallKit = false
                    envConfigSubject.selectedMeetingType = .teamsMeeting
                    envConfigSubject.skipSetupScreen = false
                    await startCallComposite()
                } else if EnvConfig.skipTo.value() == "GroupCallScreen" {
                    envConfigSubject.enableCallKit = false
                    envConfigSubject.selectedMeetingType = .groupCall
                    envConfigSubject.skipSetupScreen = true
                    await startCallComposite()
                } else if EnvConfig.skipTo.value() == "GroupSetupScreen" {
                    envConfigSubject.enableCallKit = false
                    envConfigSubject.selectedMeetingType = .groupCall
                    envConfigSubject.skipSetupScreen = false
                    await startCallComposite()
                }
            }
        })
        #endif
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

    var userIdTextField: some View {
        TextField("User Identifier", text: $envConfigSubject.userId)
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
                    "Team Meeting Link",
                    text: $envConfigSubject.teamsMeetingLink)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                TextField(
                    "Team Meeting Id",
                    text: $envConfigSubject.teamsMeetingId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                TextField(
                    "Team Meeting Passcode",
                    text: $envConfigSubject.teamsMeetingPasscode)
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

        if envConfigSubject.selectedMeetingType == .groupCall && envConfigSubject.groupCallId.isEmpty {
            return true
        } else if envConfigSubject.selectedMeetingType == .teamsMeeting {
            // Check if teamsMeetingLink is not empty or both meetingId and passcode are not empty
            let isTeamsMeetingLinkValid = !envConfigSubject.teamsMeetingLink.isEmpty
            let isTeamsMeetingIdAndPasscodeValid = !envConfigSubject.teamsMeetingId.isEmpty
            && !envConfigSubject.teamsMeetingPasscode.isEmpty
            return !isTeamsMeetingLinkValid
            && !isTeamsMeetingIdAndPasscodeValid
        }
        return false
    }
}

extension CallingDemoView {
    func showCallComposite() {
        callingViewModel.callComposite?.isHidden = false
    }

    func registerPushNotification() {
        Task {
            guard let token = $envConfigSubject.deviceToken.wrappedValue else {
                showAlert(for: "deviceToken not found")
                return
            }
            await createCallComposite()?
                .registerPushNotifications(
                    deviceRegistrationToken: token) { result in
                            switch result {
                            case .success:
                                showAlert(for: "Register Voip Success")
                            case .failure(let error):
                                showAlert(for: "Register Voip fail: \(error.localizedDescription)")
                            }
                }
        }
    }

    func unregisterPushNotification() {
        Task {
            await createCallComposite()?
                .unregisterPushNotifications { result in
                            switch result {
                            case .success:
                                showAlert(for: "Unregister Voip Success")
                            case .failure(let error):
                                showAlert(for: "Unregister Voip fail: \(error.localizedDescription)")
                            }
                }
        }
    }

    func accept() {
        Task {
            var remoteInfoDisplayName = envConfigSubject.callkitRemoteInfo
            if remoteInfoDisplayName.isEmpty {
                remoteInfoDisplayName = "ACS \(envConfigSubject.selectedMeetingType)"
            }
            let cxHandle = CXHandle(type: .generic, value: getCXHandleName())
            let callKitRemoteInfo = $envConfigSubject.enableRemoteInfo.wrappedValue ?
            CallKitRemoteInfo(displayName: remoteInfoDisplayName,
                                     handle: cxHandle) : nil
            isIncomingCall = false
            await createCallComposite()?.accept(incomingCallId: incomingCallId,
                                                callKitRemoteInfo: callKitRemoteInfo,
                                                localOptions: getLocalOptions())
        }
    }

    func decline() {
        Task {
            isIncomingCall = false
            await createCallComposite()?.reject(incomingCallId: incomingCallId) { result in
                switch result {
                case .success:
                    showAlert(for: "Reject Success")
                case .failure(let error):
                    showAlert(for: "Reject fail: \(error.localizedDescription)")
                }
            }
        }
    }

    fileprivate func relaunchComposite() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Task { @MainActor in
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
        let setupScreenOptions = SetupScreenOptions(
            cameraButtonEnabled: envConfigSubject.setupScreenOptionsCameraButtonEnabled,
            microphoneButtonEnabled: envConfigSubject.setupScreenOptionsMicButtonEnabled)
        /* <TIMER_TITLE_FEATURE> */
        headerViewData = CallScreenHeaderViewData()
        if !envConfigSubject.callInformationTitle.isEmpty {
            headerViewData?.title = envConfigSubject.callInformationTitle
        }
        if !envConfigSubject.callInformationSubtitle.isEmpty {
            headerViewData?.subtitle = envConfigSubject.callInformationSubtitle
        }
        /* </TIMER_TITLE_FEATURE> */
        var callScreenOptions = CallScreenOptions(controlBarOptions: barOptions /* <TIMER_TITLE_FEATURE> */ ,
                                                   headerViewData: headerViewData
                                                   /* </TIMER_TITLE_FEATURE> */ )
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

    func onPushNotificationReceived(dictionaryPayload: [AnyHashable: Any]) {
        let pushNotificationInfo = PushNotification(data: dictionaryPayload)
        os_log("calling demo app: onPushNotificationReceived CallingDemoView")
        if envConfigSubject.acsToken.isEmpty {
            os_log("calling demo app: envConfigSubject acs token is empty")
            self.envConfigSubject.load()
        }
        Task {
            await createCallComposite()?.handlePushNotification(pushNotification: pushNotificationInfo)
        }
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
            print("::::CallingDemoView::onDismissedHandler")
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
            isIncomingCall = false
            callComposite?.launch(callIdAcceptedFromCallKit: callId, localOptions: getLocalOptions())
        }

        let onIncomingCall: (IncomingCall) -> Void = { [] incomingCall in
            incomingCallId = incomingCall.callId
            isIncomingCall = true
            print("::::CallingDemoView::onIncomingCall \(incomingCall.callId)")
        }

        let onIncomingCallCancelled: (IncomingCallCancelled) -> Void = { [] event in
            isIncomingCall = false
            print("::::CallingDemoView::onIncomingCallCancelled \(event.callId)")
            showAlert(for: "\(event.callId) cancelled")
        }
        /* <TIMER_TITLE_FEATURE> */
        let onRemoteParticipantLeftHandler: ([CommunicationIdentifier]) -> Void = { [weak callComposite] ids in
            guard let composite = callComposite else {
                return
            }
            self.onRemoteParticipantLeft(to: composite,
                                           identifiers: ids)
        }
        /* </TIMER_TITLE_FEATURE> */
        callComposite.events.onRemoteParticipantJoined = onRemoteParticipantJoinedHandler
        callComposite.events.onError = onErrorHandler
        callComposite.events.onCallStateChanged = onCallStateChangedHandler
        callComposite.events.onDismissed = onDismissedHandler
        callComposite.events.onPictureInPictureChanged = onPipChangedHandler
        callComposite.events.onUserReportedIssue = onUserReportedIssueHandler
        callComposite.events.onIncomingCallAcceptedFromCallKit = callKitCallAccepted
        callComposite.events.onIncomingCall = onIncomingCall
        callComposite.events.onIncomingCallCancelled = onIncomingCallCancelled
        /* <TIMER_TITLE_FEATURE> */
        callComposite.events.onRemoteParticipantLeft = onRemoteParticipantLeftHandler
        /* </TIMER_TITLE_FEATURE> */
    }

    func getLocalOptions(callComposite: CallComposite? = nil) -> LocalOptions {
        let renderDisplayName = envConfigSubject.renderedDisplayName.isEmpty ?
                                nil : envConfigSubject.renderedDisplayName
        let participantViewData = ParticipantViewData(avatar: UIImage(named: envConfigSubject.avatarImageName),
                                                      displayName: renderDisplayName)
        let setupScreenViewData = SetupScreenViewData(title: envConfigSubject.navigationTitle,
                                                          subtitle: envConfigSubject.navigationSubtitle)
        let captionsOptions = CaptionsOptions(captionsOn: envConfigSubject.captionsOn,
                                              spokenLanguage: envConfigSubject.spokenLanguage)

        let controlBarOptions = CallScreenControlBarOptions(leaveCallConfirmationMode:
                                                                envConfigSubject.displayLeaveCallConfirmation ?
            .alwaysEnabled : .alwaysDisabled)
        var callScreenOptions = CallScreenOptions(controlBarOptions: controlBarOptions)
        if envConfigSubject.addCustomButton {
            callScreenOptions = createCallScreenOptions(callComposite: callComposite)
        }
        if envConfigSubject.hideAllButtons {
            callScreenOptions = hideAllButtons()
        }
        return LocalOptions(participantViewData: participantViewData,
                                        setupScreenViewData: setupScreenViewData,
                                        cameraOn: envConfigSubject.cameraOn,
                                        microphoneOn: envConfigSubject.microphoneOn,
                                        skipSetupScreen: envConfigSubject.skipSetupScreen,
                                        audioVideoMode: envConfigSubject.audioOnly ? .audioOnly : .audioAndVideo,
                            captionsOptions: captionsOptions, callScreenOptions: callScreenOptions
        )
    }

    private func createCallScreenOptions(callComposite: CallComposite?) -> CallScreenOptions {
        // Safely unwrap the image and apply the tint color using the color set named "ChevronColor"
        let customButtonImage: UIImage
        if let image = UIImage(named: "ic_fluent_chevron_right_20_regular") {
            customButtonImage = image.withRenderingMode(.alwaysOriginal)
        } else {
            customButtonImage = UIImage().withTintColor(.black) // Fallback to a plain image with black tint
            print("Error: Image 'ic_fluent_chevron_right_20_regular' not found")
        }

        // Create the custom button with the tinted image
        let customButton1 = CustomButtonViewData(
            id: UUID().uuidString,
            image: customButtonImage,
            title: "Hide composite"
        ) { _ in
            print("::::SwiftUIDemoView::CallScreen::customButton1::onClick")
            callComposite?.isHidden = true
        }

        let customButton2 = CustomButtonViewData(
            id: UUID().uuidString,
            image: customButtonImage,
            title: "Troubleshooting tips"
        ) { _ in
            print("::::SwiftUIDemoView::CallScreen::customButton2::onClick")
            callComposite?.isHidden = true
            $isNewViewPresented.wrappedValue = true
        }
        // Create and return the CallScreenControlBarOptions
        let callScreenControlBarOptions = CallScreenControlBarOptions(
            leaveCallConfirmationMode: envConfigSubject.displayLeaveCallConfirmation ? .alwaysEnabled : .alwaysDisabled,
            customButtons: [customButton1, customButton2]
        )

        return CallScreenOptions(controlBarOptions: callScreenControlBarOptions)
    }

    func hideAllButtons() -> CallScreenOptions {
        let callScreenControlBarOptions = CallScreenControlBarOptions(
            leaveCallConfirmationMode: envConfigSubject.displayLeaveCallConfirmation ? .alwaysEnabled : .alwaysDisabled,
            liveCaptionsButton: ButtonViewData(visible: false),
            liveCaptionsToggleButton: ButtonViewData(visible: false),
            spokenLanguageButton: ButtonViewData(visible: false),
            captionsLanguageButton: ButtonViewData(visible: false),
            shareDiagnosticsButton: ButtonViewData(visible: false),
            reportIssueButton: ButtonViewData(visible: false)
        )
        return CallScreenOptions(controlBarOptions: callScreenControlBarOptions)
    }

    func startCallWithDeprecatedLaunch() async {
        if let credential = try? await getTokenCredential(),
           let callComposite = try? await createCallComposite() {
            let link = getMeetingLink()
            var localOptions = getLocalOptions(callComposite: callComposite)
            switch envConfigSubject.selectedMeetingType {
            case .groupCall:
                let uuid = try? parseUUID(from: link)
                // Checking if UUID parsing was successful
                if let uuid = uuid {
                    if envConfigSubject.displayName.isEmpty {
                        // Launch call composite without displayName
                        callComposite.launch(remoteOptions: RemoteOptions(for: .groupCall(groupId: uuid),
                                                                          credential: credential),
                                             localOptions: localOptions)
                    } else {
                        // Launch call composite with displayName
                        callComposite.launch(remoteOptions: RemoteOptions(for: .groupCall(groupId: uuid),
                                                                          credential: credential,
                                                                          displayName: envConfigSubject.displayName),
                                             localOptions: localOptions)
                    }
                } else {
                    // Handle the case where UUID parsing fails
                    showError(for: DemoError.invalidGroupCallId.getErrorCode())
                    return
                }
            case .teamsMeeting:
                if !envConfigSubject.teamsMeetingLink.isEmpty {
                    if envConfigSubject.displayName.isEmpty {
                        callComposite.launch(
                            remoteOptions: RemoteOptions(for: .teamsMeeting(teamsLink:
                                                                                envConfigSubject.teamsMeetingLink),
                                                         credential: credential),
                            localOptions: localOptions
                        )
                    } else {
                        callComposite.launch(
                            remoteOptions: RemoteOptions(for: .teamsMeeting(teamsLink:
                                                                                envConfigSubject.teamsMeetingLink),
                                                         credential: credential,
                                                         displayName: envConfigSubject.displayName),
                            localOptions: localOptions
                        )
                    }
                } else if !envConfigSubject.teamsMeetingId.isEmpty && !envConfigSubject.teamsMeetingPasscode.isEmpty {
                    if envConfigSubject.displayName.isEmpty {
                        callComposite.launch(
                            remoteOptions: RemoteOptions(for: .teamsMeetingId(meetingId:
                                                                                envConfigSubject.teamsMeetingId,
                                                                              meetingPasscode:
                                                                                envConfigSubject.teamsMeetingPasscode),
                                                         credential: credential),
                            localOptions: localOptions
                        )
                    } else {
                        callComposite.launch(
                            remoteOptions: RemoteOptions(for: .teamsMeetingId(meetingId:
                                                                                envConfigSubject.teamsMeetingId,
                                                                              meetingPasscode:
                                                                                envConfigSubject.teamsMeetingPasscode),
                                                         credential: credential,
                                                         displayName: envConfigSubject.displayName),
                            localOptions: localOptions
                        )
                    }
                }
            case .oneToNCall:
                let ids: [String] = link.split(separator: ",").map {
                    String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                let communicationIdentifiers: [CommunicationIdentifier] =
                ids.map { createCommunicationIdentifier(fromRawId: $0) }
                callComposite.launch(participants: communicationIdentifiers,
                                     localOptions: localOptions)
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
            }
        }
    }

    func startCallComposite() async {
        let link = getMeetingLink()
        if let callComposite = try? await createCallComposite() {
            var localOptions = getLocalOptions(callComposite: callComposite)
            var remoteInfoDisplayName = envConfigSubject.callkitRemoteInfo
            if remoteInfoDisplayName.isEmpty {
                remoteInfoDisplayName = "ACS \(envConfigSubject.selectedMeetingType)"
            }
            let cxHandle = CXHandle(type: .generic, value: getCXHandleName())
            isIncomingCall = false
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

                case .oneToNCall:
                    let ids: [String] = link.split(separator: ",").map {
                        String($0).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    let communicationIdentifiers: [CommunicationIdentifier] =
                    ids.map { createCommunicationIdentifier(fromRawId: $0) }
                    callComposite.launch(participants: communicationIdentifiers,
                                         callKitRemoteInfo: callKitRemoteInfo,
                                         localOptions: localOptions)
                case .roomCall:
                    callComposite.launch(
                        locator: .roomCall(roomId: link),
                        callKitRemoteInfo: callKitRemoteInfo,
                        localOptions: localOptions)
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
        let options: AVAudioSession.CategoryOptions = .allowBluetooth
        var configError: Error?
        do {
            try audioSession.setCategory(.playAndRecord, options: options)
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

    private func parseUUID(from link: String) throws -> UUID {
        guard let uuid = UUID(uuidString: link) else {
            throw DemoError.invalidGroupCallId
        }
        return uuid
    }

    private func getMeetingLink() -> String {
        switch envConfigSubject.selectedMeetingType {
        case .groupCall:
            return envConfigSubject.groupCallId
        case .teamsMeeting:
            return envConfigSubject.teamsMeetingLink
        case .oneToNCall:
            return envConfigSubject.participantMRIs
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
        default:
            alertMessage = "Unknown error"
        }
        alertTitle = "Error"
        isAlertDisplayed = true
    }

    private func showAlert(for message: String) {
        alertMessage = message
        alertTitle = "Alert"
        isAlertDisplayed = true
    }

    private func onError(_ error: CallCompositeError, callComposite: CallComposite) {
        print("::::CallingDemoView::getEventsHandler::onError \(error)")
        print("::::CallingDemoView error.code \(error.code)")
        callingViewModel.callHistory.last?.callIds.forEach { print("::::CallingDemoView call id \($0)") }
        showError(for: error.code)
    }

    private func onCallStateChanged(_ callState: CallState, callComposite: CallComposite) {
        print("::::CallingDemoView::getEventsHandler::onCallStateChanged \(callState.requestString)")
        self.callState = "\(callState.requestString) \(callState.callEndReasonCodeInt) \(callState.callId)"
    }

    private func onRemoteParticipantJoined(to callComposite: CallComposite,
                                           identifiers: [CommunicationIdentifier]) {
        print("::::CallingDemoView::getEventsHandler::onRemoteParticipantJoined \(identifiers)")
        /* <TIMER_TITLE_FEATURE> */
        if envConfigSubject.customTitleApplyOnRemoteJoin != 0 &&
            identifiers.count >= envConfigSubject.customTitleApplyOnRemoteJoin {
            headerViewData?.title = "Custom title: change applied"
        }
        if envConfigSubject.customSubtitleApplyOnRemoteJoin != 0 &&
            identifiers.count >= envConfigSubject.customSubtitleApplyOnRemoteJoin {
            headerViewData?.subtitle = "Custom subtitle: change applied"
        }
        /* </TIMER_TITLE_FEATURE> */
        guard envConfigSubject.useCustomRemoteParticipantViewData else {
            return
        }

        RemoteParticipantAvatarHelper.onRemoteParticipantJoined(to: callComposite,
                                                                identifiers: identifiers)

        // Check identifiers to use the the stop/start timer API based on a specific participant leaves the meeting.
    }
    /* <TIMER_TITLE_FEATURE> */
    private func onRemoteParticipantLeft(to callComposite: CallComposite, identifiers: [CommunicationIdentifier]) {
        print("::::CallingDemoView::getEventsHandler::onRemoteParticipantLeft \(identifiers)")

        // Check identifiers to use the the stop/start timer API based on a specific participant leaves the meeting.
    }
    /* </TIMER_TITLE_FEATURE> */
}

struct CustomDemoView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("This is a new view presented modally.")
                .font(.largeTitle)
                .padding()

            Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.opacity(0.1))
    }
}

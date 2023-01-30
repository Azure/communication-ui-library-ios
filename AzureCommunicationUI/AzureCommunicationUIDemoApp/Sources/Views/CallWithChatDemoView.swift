//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationCommon
import AzureCommunicationUICalling
import AzureCommunicationUIChat

struct CallWithChatDemoView: View {
    @State var chatAdapter: ChatAdapter?
    @State var callComposite: CallComposite?
    @State var isErrorDisplayed: Bool = false
    @State var isSettingsDisplayed: Bool = false
    @State var isStartExperienceLoading: Bool = false
    @State var errorMessage: String = ""
    @ObservedObject var envConfigSubject: EnvConfigSubject

    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10

    var body: some View {
        VStack {
            Text("UI Library - SwiftUI Sample")
            Spacer()
            launchView
            Spacer()
        }
        .padding()
        .alert(isPresented: $isErrorDisplayed) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton:
                        .default(Text("Dismiss"), action: {
                            isErrorDisplayed = false
                        }))
        }
        .sheet(isPresented: $isSettingsDisplayed) {
            SettingsView(envConfigSubject: envConfigSubject)
        }
    }

    var launchView: some View {
        VStack {
            acsTokenSelector
            displayNameTextField
            userIdField
            endpointUrlField
            meetingSelector
            startExperienceButton
        }
        .padding()
    }

    //    var chatView: some View {
    //        VStack {
    //            if let chatAdapter = chatAdapter {
    //                ChatCompositeView(with: chatAdapter)
    //                    .navigationTitle("Chat")
    //                    .navigationBarTitleDisplayMode(.inline)
    //            } else {
    //                EmptyView()
    //                    .navigationTitle("Failed to start chat")
    //                    .navigationBarTitleDisplayMode(.inline)
    //            }
    //        }
    //    }

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

    var userIdField: some View {
        TextField("Communication User Id", text: $envConfigSubject.userId)
            .disableAutocorrection(true)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .textFieldStyle(.roundedBorder)
    }

    var endpointUrlField: some View {
        TextField("ACS Endpoint Url", text: $envConfigSubject.endpointUrl)
            .disableAutocorrection(true)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .textFieldStyle(.roundedBorder)
    }

    var meetingSelector: some View {
        TextField(
            "Group Chat ThreadId",
            text: $envConfigSubject.threadId)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .textFieldStyle(.roundedBorder)
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }

    //    var acsTokenSelector: some View {
    //        Group {
    //            Picker("Token Type", selection: $envConfigSubject.selectedAcsTokenType) {
    //                Text("Token URL").tag(ACSTokenType.tokenUrl)
    //                Text("Token").tag(ACSTokenType.token)
    //            }.pickerStyle(.segmented)
    //            switch envConfigSubject.selectedAcsTokenType {
    //            case .tokenUrl:
    //                TextField("ACS Token URL", text: $envConfigSubject.acsTokenUrl)
    //                    .disableAutocorrection(true)
    //                    .autocapitalization(.none)
    //                    .textFieldStyle(.roundedBorder)
    //            case .token:
    //                TextField("ACS Token", text:
    //                            !envConfigSubject.useExpiredToken ?
    //                          $envConfigSubject.acsToken : $envConfigSubject.expiredAcsToken)
    //                    .modifier(TextFieldClearButton(text: $envConfigSubject.acsToken))
    //                    .disableAutocorrection(true)
    //                    .autocapitalization(.none)
    //                    .textFieldStyle(.roundedBorder)
    //            }
    //        }
    //        .padding(.vertical, verticalPadding)
    //        .padding(.horizontal, horizontalPadding)
    //    }
    //
    //    var displayNameTextField: some View {
    //        TextField("Display Name", text: $envConfigSubject.displayName)
    //            .disableAutocorrection(true)
    //            .padding(.vertical, verticalPadding)
    //            .padding(.horizontal, horizontalPadding)
    //            .textFieldStyle(.roundedBorder)
    //    }
    //
    //    var meetingSelector: some View {
    //        Group {
    //            Picker("Call Type", selection: $envConfigSubject.selectedMeetingType) {
    //                Text("Group Call").tag(MeetingType.groupCall)
    //                Text("Teams Meeting").tag(MeetingType.teamsMeeting)
    //            }.pickerStyle(.segmented)
    //            switch envConfigSubject.selectedMeetingType {
    //            case .groupCall:
    //                TextField(
    //                    "Group Call Id",
    //                    text: $envConfigSubject.groupCallId)
    //                    .autocapitalization(.none)
    //                    .disableAutocorrection(true)
    //                    .textFieldStyle(.roundedBorder)
    //            case .teamsMeeting:
    //                TextField(
    //                    "Team Meeting",
    //                    text: $envConfigSubject.teamsMeetingLink)
    //                    .autocapitalization(.none)
    //                    .disableAutocorrection(true)
    //                    .textFieldStyle(.roundedBorder)
    //            }
    //        }
    //        .padding(.vertical, verticalPadding)
    //        .padding(.horizontal, horizontalPadding)
    //    }
    //
    //    var settingButton: some View {
    //        Button("Settings") {
    //            isSettingsDisplayed = true
    //        }
    //        .buttonStyle(DemoButtonStyle())
    //        .accessibility(identifier: AccessibilityId.settingsButtonAccessibilityID.rawValue)
    //    }

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

    var isStartExperienceDisabled: Bool {
        let acsToken = envConfigSubject.useExpiredToken ? envConfigSubject.expiredAcsToken : envConfigSubject.acsToken
        if (envConfigSubject.selectedAcsTokenType == .token && acsToken.isEmpty)
            || envConfigSubject.selectedAcsTokenType == .tokenUrl && envConfigSubject.acsTokenUrl.isEmpty
            || envConfigSubject.threadId.isEmpty {
            return true
        }

        return false

        //        let acsToken = envConfigSubject.useExpiredToken ? envConfigSubject.expiredAcsToken :
        // envConfigSubject.acsToken
        //        if (envConfigSubject.selectedAcsTokenType == .token && acsToken.isEmpty)
        //            || envConfigSubject.selectedAcsTokenType == .tokenUrl && envConfigSubject.acsTokenUrl.isEmpty {
        //            return true
        //        }
        //
        //        if (envConfigSubject.selectedMeetingType == .groupCall && envConfigSubject.groupCallId.isEmpty)
        //            || envConfigSubject.selectedMeetingType == .teamsMeeting
        // && envConfigSubject.teamsMeetingLink.isEmpty {
        //            return true
        //        }
        //
        //        return false
    }
}

extension CallWithChatDemoView {
    func startCallComposite() async {
        let link = envConfigSubject.groupCallId

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
            localization: localizationConfig,
            customizationOptions: createCustomizationOption())

        let callComposite = CallComposite(withOptions: callCompositeOptions)

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
        callComposite.events.onRemoteParticipantJoined = onRemoteParticipantJoinedHandler
        callComposite.events.onError = onErrorHandler

        let renderDisplayName = envConfigSubject.renderedDisplayName.isEmpty ?
        nil:envConfigSubject.renderedDisplayName
        let participantViewData = ParticipantViewData(avatar: UIImage(named: envConfigSubject.avatarImageName),
                                                      displayName: renderDisplayName)
        let setupScreenViewData = SetupScreenViewData(title: envConfigSubject.navigationTitle,
                                                      subtitle: envConfigSubject.navigationSubtitle)
        let localOptions = LocalOptions(participantViewData: participantViewData,
                                        setupScreenViewData: setupScreenViewData)
        if let credential = try? await getTokenCredential() {
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
        } else {
            showError(for: DemoError.invalidToken.getErrorCode())
            return
        }
    }

    func startChatComposite() {
        let communicationIdentifier = CommunicationUserIdentifier(envConfigSubject.userId)
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token: envConfigSubject.acsToken) else {
            return
        }

        self.chatAdapter = ChatAdapter(
            endpoint: envConfigSubject.endpointUrl,
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: envConfigSubject.threadId,
            displayName: envConfigSubject.displayName)
        guard let chatAdapter = self.chatAdapter else {
            return
        }
        chatAdapter.events.onError = showError(error:)
        chatAdapter.connect() { _ in
            print("Chat connect completionHandler called")
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

    //    private func getMeetingLink() -> String {
    //        switch envConfigSubject.selectedMeetingType {
    //        case .groupCall:
    //            return envConfigSubject.groupCallId
    //        case .teamsMeeting:
    //            return envConfigSubject.teamsMeetingLink
    //        }
    //    }

    private func showError(for errorCode: String) {
        switch errorCode {
        case CallCompositeErrorCode.tokenExpired:
            errorMessage = "Token is invalid"
        default:
            errorMessage = "Unknown error"
        }
        isErrorDisplayed = true
    }

    private func onError(_ error: CallCompositeError, callComposite: CallComposite) {
        print("::::CallingDemoView::getEventsHandler::onError \(error)")
        print("::::CallingDemoView error.code \(error.code)")
        print("::::CallingDemoView debug info \(callComposite.debugInfo.currentOrLastCallId ?? "Unknown")")
        showError(for: error.code)
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

extension CallWithChatDemoView {
    private func createCustomizationOption() -> CustomizationOptions {
        let messageBtnState = getMessageButtonViewData()
        return CustomizationOptions(customButtonViewData: [messageBtnState])
    }

    private func getMessageButtonViewData() -> CustomButtonViewData {
        let state = CustomButtonViewData(type: .callingViewInfoHeader,
                                         image: UIImage(named: "messageIcon")!,
                                         label: "messageIcon",
                                         badgeNumber: 0) { [weak callComposite = self.callComposite,
                                                            weak chatAdapter = self.chatAdapter] _ in
            guard let callComposite = callComposite,
                  let chatCompositeAdaptor = chatAdapter else {
                return
            }

            let chatCompositeView = ChatCompositeView(with: chatCompositeAdaptor)
                .navigationTitle("Chat")
                .navigationBarTitleDisplayMode(.inline)
            //            guard let chatCompositeView = try? self.chatComposite?.getCompositeView() else {
            //                print("Couldn't show Chat Composite UI")
            //                return
            //            }
            //            guard let chatCompositeViewController =
            // try? self.chatComposite?.getCompositeViewController() else {
            //                print("Couldn't show Chat Composite UI")
            //                return
            //            }

            //            let pipOptions = PIPViewOptions(
            //                isDraggable: true,
            //                pipDraggableAreaMargins: UIEdgeInsets(top: 60, left: 12, bottom: 82, right: 12),
            //                defaultPosition: .bottomRight)
            //            let overlayOptions = OverlayOptions(overlayTransition: .move(edge: .trailing),
            //                                                showPIP: true,
            //                                                pipViewOptions: pipOptions)
//            callComposite?.setOverlay(chatCompositeViewController)// ,
            // overlayOptions: overlayOptions)
            // SwiftUI version
            //            self.callComposite?.setOverlay(overlayOptions: overlayOptions, overlay: {
            //                chatCompositeView
            //            })
        }

        return state
    }
}

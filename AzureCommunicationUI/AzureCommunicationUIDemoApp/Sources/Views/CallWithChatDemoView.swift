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
    @State var loadingChat: Bool = false

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
            endpointUrlField
            meetingSelector
            startExperienceButton
        }
        .padding()
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
                userIdField
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
        Group {
            Picker("Call Type", selection: $envConfigSubject.selectedMeetingType) {
                Text("Group Call with Chat").tag(MeetingType.groupCall)
                Text("Teams Meeting").tag(MeetingType.teamsMeeting)
            }.pickerStyle(.segmented)
            switch envConfigSubject.selectedMeetingType {
            case .groupCall:
                TextField(
                    "Group Call Id",
                    text: $envConfigSubject.groupCallId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                TextField(
                    "Group Chat ThreadId",
                    text: $envConfigSubject.threadId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            case .teamsMeeting:
                TextField(
                    "Teams Meeting",
                    text: $envConfigSubject.teamsMeetingLink)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
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

    var isStartExperienceDisabled: Bool {
        let acsToken = envConfigSubject.useExpiredToken ? envConfigSubject.expiredAcsToken :
        envConfigSubject.acsToken
        if (envConfigSubject.selectedAcsTokenType == .token && acsToken.isEmpty)
            || envConfigSubject.selectedAcsTokenType == .tokenUrl && envConfigSubject.acsTokenUrl.isEmpty {
            return true
        }

        let groupIsStartExperienceDisabledCheck = envConfigSubject.selectedMeetingType == .groupCall
        && (envConfigSubject.groupCallId.isEmpty || envConfigSubject.threadId.isEmpty)
        let teamsIsStartExperienceDisabledCheck = (envConfigSubject.selectedMeetingType == .teamsMeeting
                                                   && envConfigSubject.teamsMeetingLink.isEmpty)

        if groupIsStartExperienceDisabledCheck || teamsIsStartExperienceDisabledCheck {
            return true
        }

        return false
    }
}

extension CallWithChatDemoView {
    func startCallComposite() async {
        let link = getMeetingLink()

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
        self.callComposite = callComposite

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
        callComposite.events.onCallStatusChanged = { status in
            switch status {
            case .connected:
                if !loadingChat && self.chatAdapter == nil {
                    self.loadingChat = true
                    Task { @MainActor in
                        await self.startChatComposite()
                    }
                }
            case .disconnected:
                guard let chatAdapter = self.chatAdapter else {
                    self.callComposite = nil
                    return
                }
                Task { @MainActor in
                    do {
                        try await chatAdapter.disconnect()
                        self.chatAdapter = nil
                    } catch {
                        print("Chat disconnect error \(error)")
                    }
                    self.callComposite = nil
                }

            default:
                print(status)
            }
        }

        let renderDisplayName = envConfigSubject.renderedDisplayName.isEmpty ?
        nil:envConfigSubject.renderedDisplayName
        let participantViewData = ParticipantViewData(avatar: UIImage(named: envConfigSubject.avatarImageName),
                                                      displayName: renderDisplayName)
        let setupScreenViewData = SetupScreenViewData(title: envConfigSubject.navigationTitle,
                                                      subtitle: envConfigSubject.navigationSubtitle)
        let localOptions = LocalOptions(participantViewData: participantViewData,
                                        setupScreenViewData: setupScreenViewData)
        if let credential = try? await getTokenCredential() {
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
            }
        } else {
            showCallError(for: DemoError.invalidToken.getErrorCode())
            return
        }
    }

    func startChatComposite() async {
        loadingChat = true
        let communicationIdentifier = CommunicationUserIdentifier(envConfigSubject.userId)
        guard let communicationTokenCredential = try? await self.getTokenCredential(),
              let teamsMeetingLink = envConfigSubject.teamsMeetingLink.removingPercentEncoding else {
                  return
              }
        var threadId = ""
        switch envConfigSubject.selectedMeetingType {
        case .groupCall:
            threadId = envConfigSubject.threadId
        case .teamsMeeting:
            if let threadMatcher = try? NSRegularExpression(
                pattern: "(.*meetup-join\\/)(?<threadId>19.*)(\\/.*)"
            ) {
                let matches = threadMatcher.matches(
                    in: teamsMeetingLink,
                    range: NSRange(
                        teamsMeetingLink.startIndex..<teamsMeetingLink.endIndex,
                        in: teamsMeetingLink
                    )
                )
                if let matchedRange = matches.first?.range(withName: "threadId"),
                   let substringRange = Range(matchedRange, in: teamsMeetingLink) {
                    threadId = String(teamsMeetingLink[substringRange])
                }
            } else {
                fatalError("Regular expression is invalid!")
            }
        }
        self.chatAdapter = ChatAdapter(
            endpoint: envConfigSubject.endpointUrl,
            identifier: communicationIdentifier,
            credential: communicationTokenCredential,
            threadId: threadId,
            displayName: envConfigSubject.displayName)
        guard let chatAdapter = self.chatAdapter else {
            return
        }
        chatAdapter.events.onError = showChatError(error:)
        do {
            try await chatAdapter.connect()
            print("Chat connected")
        } catch {
            print(error)
        }
        loadingChat = false
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
        }
    }

    private func showCallError(for errorCode: String) {
        switch errorCode {
        case CallCompositeErrorCode.tokenExpired:
            errorMessage = "Token is invalid"
        default:
            errorMessage = "Unknown error"
        }
        isErrorDisplayed = true
    }

    private func onError(_ error: CallCompositeError, callComposite: CallComposite) {
        print("::::CallWithChatDemoView::getEventsHandler::onError \(error)")
        print("::::CallWithChatDemoView error.code \(error.code)")
        print("::::CallWithChatDemoView debug info \(callComposite.debugInfo.currentOrLastCallId ?? "Unknown")")
        showCallError(for: error.code)
    }

    private func onRemoteParticipantJoined(to callComposite: CallComposite, identifiers: [CommunicationIdentifier]) {
        print("::::CallWithChatDemoView::getEventsHandler::onRemoteParticipantJoined \(identifiers)")
        guard envConfigSubject.useCustomRemoteParticipantViewData else {
            return
        }

        RemoteParticipantAvatarHelper.onRemoteParticipantJoined(to: callComposite,
                                                                identifiers: identifiers)
    }

    private func showChatError(error: ChatCompositeError) {
        print("::::CallWithChatDemoView::showChatError \(error)")
        print("::::CallWithChatDemoView error.code \(error.code)")
        print("Error - \(error.code): \(error.error?.localizedDescription ?? error.localizedDescription)")
        switch error.code {
        case ChatCompositeErrorCode.joinFailed:
            errorMessage = "Connection Failed"
        case ChatCompositeErrorCode.disconnectFailed:
            errorMessage = "Disconnect Failed"
        case ChatCompositeErrorCode.sendMessageFailed,
            ChatCompositeErrorCode.fetchMessagesFailed,
            ChatCompositeErrorCode.requestParticipantsFetchFailed,
            ChatCompositeErrorCode.sendReadReceiptFailed,
            ChatCompositeErrorCode.sendTypingIndicatorFailed,
            ChatCompositeErrorCode.disconnectFailed:
            // no alert
            return
        default:
            errorMessage = "Unknown error"
        }
        isErrorDisplayed = true
    }
}

extension CallWithChatDemoView {
    private func createCustomizationOption() -> CustomizationOptions {
        let messageBtnState = getMessageButtonViewData()
        return CustomizationOptions(customButtonViewData: [messageBtnState])
    }

    private func getMessageButtonViewData() -> CustomButtonViewData {
        let state = CustomButtonViewData(
            type: .callingViewInfoHeader,
            image: UIImage(named: "messageIcon")!,
            label: "messageIcon") { _ in
                guard let callComposite = self.callComposite,
                      let chatCompositeAdaptor = self.chatAdapter else {
                    return
                }

                let chatCompositeView = ChatCompositeView(with: chatCompositeAdaptor)
                    .navigationTitle("Chat")
                    .navigationBarTitleDisplayMode(.inline)
                callComposite.setOverlay(overlay: {
                    NavigationView {
                        chatCompositeView
                            .navigationTitle("Chat")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button {
                                        callComposite.removeOverlay()
                                    } label: {
                                        Text("Back")
                                    }
                                }
                            }
                    }
                    .transition(.move(edge: .trailing))
                })
        }

        return state
    }
}

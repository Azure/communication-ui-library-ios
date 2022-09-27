//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

import AzureCommunicationChat
import AzureCommunicationCommon
import AzureCommunicationUIChat
import AzureCommunicationUICallWithChat

enum DemoViewType {
    case chat
    case callWithChat
}

struct CredentialsView: View {
    @State var isErrorDisplayed: Bool = false
    @State var isSettingsDisplayed: Bool = false
    @State var launchHeadless: Bool = true
    @State var isAlertDisplayed: Bool = false
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    @ObservedObject var envConfigSubject: EnvConfigSubject

    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10

    let viewType: DemoViewType

    let callWithChatComposite = CallWithChatComposite(withOptions: CallWithChatCompositeOptions())
    let chatComposite = ChatComposite(withOptions: ChatCompositeOptions())

    var body: some View {
        VStack {
            Text("UI Library - Chat Sample")
            acsTokenSelector
            displayNameTextField
            userIdField
            endpointUrlField
            meetingSelector
            startExperience
            if viewType == .chat {
                Divider()
                showCompositeUI
            }
            Spacer()
        }
        .padding()
        .alert(isPresented: $isAlertDisplayed) {
            Alert(title: Text(alertTitle),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
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
        Group {
            Picker("Chat Type", selection: $envConfigSubject.selectedChatType) {
                Text("Group Chat").tag(ChatType.groupChat)
                Text("Teams Meeting").tag(ChatType.teamsChat)
            }.pickerStyle(.segmented)
            switch envConfigSubject.selectedChatType {
            case .groupChat:
                TextField(
                    "Group Chat ThreadId",
                    text: $envConfigSubject.threadId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            case .teamsChat:
                TextField(
                    "Team Meeting",
                    text: $envConfigSubject.teamsMeetingLink)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }

    var startExperience: some View {
        Group {
            HStack {
                Button("Start Experience") {
                    switch viewType {
                    case .chat:
                        startChatComposite()
                    case .callWithChat:
                        startCallWithChatComposite()
                    }
                }
                .buttonStyle(DemoButtonStyle())
                .disabled(isStartExperienceDisabled)
                .accessibility(identifier: AccessibilityId.startExperienceAccessibilityID.rawValue)

                if viewType == .chat {
                    Button("Start Headless") {
                        startChatComposite(headless: true)
                    }
                    .buttonStyle(DemoButtonStyle())
                    .accessibility(identifier: AccessibilityId.stopChatAccessibilityID.rawValue)
                }
            }
        }
    }

    var showCompositeUI: some View {
        Group {
            HStack {
                Button("Show Chat UI") {
                    showChatCompositeUI()
                }
                .buttonStyle(DemoButtonStyle())
                .accessibility(identifier: AccessibilityId.showChatUIAccessibilityID.rawValue)

                Button("Stop Chat") {
                    stopChatComposite()
                }
                .buttonStyle(DemoButtonStyle())
                .accessibility(identifier: AccessibilityId.startHeadlessAccessibilityID.rawValue)
            }
        }

    }

    var isStartExperienceDisabled: Bool {
        let acsToken = envConfigSubject.useExpiredToken ? envConfigSubject.expiredAcsToken : envConfigSubject.acsToken
        if (envConfigSubject.selectedAcsTokenType == .token && acsToken.isEmpty)
            || envConfigSubject.selectedAcsTokenType == .tokenUrl && envConfigSubject.acsTokenUrl.isEmpty {
            return true
        }

        if (envConfigSubject.selectedChatType == .groupChat && envConfigSubject.threadId.isEmpty)
            || envConfigSubject.selectedChatType == .teamsChat && envConfigSubject.teamsMeetingLink.isEmpty {
            return true
        }

        return false
    }
}

extension CredentialsView {
    func startChatComposite(headless: Bool = false) {
        let communicationIdentifier = CommunicationUserIdentifier(envConfigSubject.userId)
        guard let communicationTokenCredential = try? CommunicationTokenCredential(
            token: envConfigSubject.acsToken) else {
            return
        }

        let remoteOptions = RemoteOptions(
            for: .groupChat(
                threadId: envConfigSubject.threadId,
                endpoint: envConfigSubject.endpointUrl),
            communicationIdentifier: communicationIdentifier,
            credential: communicationTokenCredential,
            displayName: envConfigSubject.displayName)
        let localOptions = AzureCommunicationUIChat.LocalOptions(
            participantViewData: ParticipantViewData(),
            isLaunchingWithUI: headless)

        chatComposite.launch(
            remoteOptions: remoteOptions,
            localOptions: localOptions)

        if headless {
            self.alertTitle = ""
            self.alertMessage = "Chat Composite has launched in background"
            self.isAlertDisplayed = true
        }
    }

    func showChatCompositeUI() {
        do {
            try self.chatComposite.showCompositeUI()
        } catch {
            self.alertTitle = "Error"
            self.alertMessage = error.localizedDescription
            self.isAlertDisplayed = true
        }
    }

    func stopChatComposite() {
        self.chatComposite.stop()
        self.alertTitle = ""
        self.alertMessage = "Chat Composite has stopped"
        self.isAlertDisplayed = true
    }

    func startCallWithChatComposite() {
        let communicationIdentifier = CommunicationUserIdentifier(envConfigSubject.userId)
        guard let communicationTokenCredential = try? getTokenCredential() else {
            return
        }

        let remoteOptions = AzureCommunicationUICallWithChat.RemoteOptions(
            for: .groupCallAndChat(callId: UUID(uuidString: envConfigSubject.groupCallId) ?? UUID(),
                                   chatThreadId: envConfigSubject.threadId,
                                   endpoint: envConfigSubject.endpointUrl),
            communicationIdentifier: communicationIdentifier,
            credential: communicationTokenCredential,
            displayName: envConfigSubject.displayName)
        callWithChatComposite.launch(remoteOptions: remoteOptions)
    }

    private func getTokenCredential() throws -> CommunicationTokenCredential {
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
                let tokenRefresher = AuthenticationHelper.getCommunicationToken(tokenUrl: url)
                let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: nil,
                                                                                        refreshProactively: true,
                                                                                        tokenRefresher: tokenRefresher)
                if let credential = try? CommunicationTokenCredential(withOptions: communicationTokenRefreshOptions) {
                    return credential
                }
            }
            throw DemoError.invalidToken
        }
    }
}

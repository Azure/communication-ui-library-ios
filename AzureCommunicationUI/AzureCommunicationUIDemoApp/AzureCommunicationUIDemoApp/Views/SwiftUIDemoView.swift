//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationUICalling
import AzureCommunicationCalling

struct SwiftUIDemoView: View {
    @State var isErrorDisplayed: Bool = false
    @State var isSettingsDisplayed: Bool = false
    @State var errorMessage: String = ""
    @ObservedObject var envConfigSubject: EnvConfigSubject

    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10

    var body: some View {
        VStack {
            Text("UI Library - SwiftUI Sample")
            Spacer()
            acsTokenSelector
            displayNameTextField
            meetingSelector
            settingButton
            startExperienceButton
            Spacer()
        }
        .padding()
        .alert(isPresented: $isErrorDisplayed) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("Dismiss")))
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
                TextField("ACS Token", text: $envConfigSubject.acsToken)
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
    }

    var startExperienceButton: some View {
        Button("Start Experience") {
            startCallComposite()
        }
        .buttonStyle(DemoButtonStyle())
        .disabled(isStartExperienceDisabled)
        .accessibility(identifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
    }

    var isStartExperienceDisabled: Bool {
        if (envConfigSubject.selectedAcsTokenType == .token && envConfigSubject.acsToken.isEmpty)
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

extension SwiftUIDemoView {
    func startCallComposite() {
        let link = getMeetingLink()

        var localizationConfig: LocalizationConfiguration?
        let layoutDirection: LayoutDirection = envConfigSubject.isRightToLeft ? .rightToLeft : .leftToRight
        if !envConfigSubject.localeIdentifier.isEmpty {
            let locale = Locale(identifier: envConfigSubject.localeIdentifier)
            localizationConfig = LocalizationConfiguration(locale: locale,
                                                           layoutDirection: layoutDirection)
        } else if !envConfigSubject.locale.identifier.isEmpty {
            localizationConfig = LocalizationConfiguration(
                locale: envConfigSubject.locale,
                layoutDirection: layoutDirection)
        }

        let callCompositeOptions = CallCompositeOptions(
            theme: envConfigSubject.useCustomColors
            ? CustomColorTheming(envConfigSubject: envConfigSubject)
            : Theming(envConfigSubject: envConfigSubject),
            localization: localizationConfig)
        let callComposite = CallComposite(withOptions: callCompositeOptions)
        callComposite.setTarget(didFail: didFail, didRemoteParticipantsJoin: didRemoteParticipantsJoin)
        let renderDisplayName = envConfigSubject.renderedDisplayName.isEmpty ?
                                nil:envConfigSubject.renderedDisplayName
        let persona = PersonaData(avatar: UIImage(named: envConfigSubject.avatarImageName),
                                                 renderDisplayName: renderDisplayName)
        let localOptions = CommunicationUILocalDataOptions(persona)
        if let credential = try? getTokenCredential() {
            switch envConfigSubject.selectedMeetingType {
            case .groupCall:
                let uuid = UUID(uuidString: link) ?? UUID()
                if envConfigSubject.displayName.isEmpty {
                    callComposite.launch(with: GroupCallOptions(credential: credential, groupId: uuid),
                                         localOptions: localOptions)
                } else {
                    callComposite.launch(with: GroupCallOptions(credential: credential,
                                                                groupId: uuid,
                                                                displayName: envConfigSubject.displayName),
                                         localOptions: localOptions)
                }
            case .teamsMeeting:
                if envConfigSubject.displayName.isEmpty {
                    callComposite.launch(with: TeamsMeetingOptions(credential: credential,
                                                                   meetingLink: link),
                                         localOptions: localOptions)
                } else {
                    callComposite.launch(with: TeamsMeetingOptions(credential: credential,
                                                                   meetingLink: link,
                                                                   displayName: envConfigSubject.displayName),
                                         localOptions: localOptions)
                }
            }
        } else {
            showError(for: DemoError.invalidToken.getErrorCode())
            return
        }
    }

    private func getTokenCredential() throws -> CommunicationTokenCredential {
        switch envConfigSubject.selectedAcsTokenType {
        case .token:
            if let communicationTokenCredential = try? CommunicationTokenCredential(token: envConfigSubject.acsToken) {
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

    private func getMeetingLink() -> String {
        switch envConfigSubject.selectedMeetingType {
        case .groupCall:
            return envConfigSubject.groupCallId
        case .teamsMeeting:
            return envConfigSubject.teamsMeetingLink
        }
    }

    private func showError(for errorCode: String) {
        switch errorCode {
        case CallCompositeErrorCode.tokenExpired:
            errorMessage = "Token is invalid"
        default:
            errorMessage = "Unknown error"
        }
        isErrorDisplayed = true
    }

    func didFail(_ error: CommunicationUIErrorEvent) {
        print("::::SwiftUIDemoView::getEventsHandler::didFail \(error)")
        print("::::SwiftUIDemoView error.code \(error.code)")
        showError(for: error.code)
    }

    func didRemoteParticipantsJoin(_ identifiers: [CommunicationIdentifier]) {
        print("::::SwiftUIDemoView::getEventsHandler::didRemoteParticipantsJoin \(identifiers)")
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationUI
import AzureCommunicationCalling

struct SwiftUIDemoView: View {
    @State var acsToken: String = EnvConfig.acsToken.value()
    @State var acsTokenUrl: String = EnvConfig.acsTokenUrl.value()
    @State var displayName: String = EnvConfig.displayName.value()
    @State var groupCallId: String = EnvConfig.groupCallId.value()
    @State var teamsMeetingLink: String = EnvConfig.teamsMeetingLink.value()
    @State var selectedAcsTokenType: ACSTokenType = .token
    @State var selectedMeetingType: MeetingType = .groupCall
    @State var isErrorDisplayed: Bool = false
    @State var errorMessage: String = ""

    let verticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10

    var body: some View {
        VStack {
            Text("UI Library - SwiftUI Sample")
            Spacer()
            acsTokenSelector
            displayNameTextField
            meetingSelector
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
    }

    var acsTokenSelector: some View {
        Group {
            Picker("Token Type", selection: $selectedAcsTokenType) {
                Text("Token URL").tag(ACSTokenType.tokenUrl)
                Text("Token").tag(ACSTokenType.token)
            }.pickerStyle(.segmented)
            switch selectedAcsTokenType {
            case .tokenUrl:
                TextField("ACS Token URL", text: $acsTokenUrl)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
            case .token:
                TextField("ACS Token", text: $acsToken)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
    }

    var displayNameTextField: some View {
        TextField("Display Name", text: $displayName)
            .disableAutocorrection(true)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .textFieldStyle(.roundedBorder)
    }

    var meetingSelector: some View {
        Group {
            Picker("Call Type", selection: $selectedMeetingType) {
                Text("Group Call").tag(MeetingType.groupCall)
                Text("Teams Meeting").tag(MeetingType.teamsMeeting)
            }.pickerStyle(.segmented)
            switch selectedMeetingType {
            case .groupCall:
                TextField(
                    "Group Call Id",
                    text: $groupCallId)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
            case .teamsMeeting:
                TextField(
                    "Team Meeting",
                    text: $teamsMeetingLink)
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
            startCallComposite()
        }
        .buttonStyle(DemoButtonStyle())
        .disabled(isStartExperienceDisabled)
    }

    var isStartExperienceDisabled: Bool {
        if (selectedAcsTokenType == .token && acsToken.isEmpty)
            || selectedAcsTokenType == .tokenUrl && acsTokenUrl.isEmpty {
            return true
        }

        if (selectedMeetingType == .groupCall && groupCallId.isEmpty)
            || selectedMeetingType == .teamsMeeting && teamsMeetingLink.isEmpty {
            return true
        }

        return false
    }
}

struct SwiftUIDemoView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIDemoView()
    }
}

extension SwiftUIDemoView {
    func startCallComposite() {
        let link = getMeetingLink()

        let callCompositeOptions = CallCompositeOptions(themeConfiguration: Theming())
        let callComposite = CallComposite(withOptions: callCompositeOptions)
        callComposite.setTarget(didFail: didFail)

        if let communicationTokenCredential = try? getTokenCredential() {
            switch selectedMeetingType {
            case .groupCall:
                let uuid = UUID(uuidString: link) ?? UUID()
                if displayName.isEmpty {
                    callComposite.launch(with: GroupCallOptions(communicationTokenCredential: communicationTokenCredential,
                                                                groupId: uuid))
                } else {
                    callComposite.launch(with: GroupCallOptions(communicationTokenCredential: communicationTokenCredential,
                                                                groupId: uuid,
                                                                displayName: displayName))
                }
            case .teamsMeeting:
                if displayName.isEmpty {
                    callComposite.launch(with: TeamsMeetingOptions(communicationTokenCredential: communicationTokenCredential,
                                                                   meetingLink: link))
                } else {
                    callComposite.launch(with: TeamsMeetingOptions(communicationTokenCredential: communicationTokenCredential,
                                                                   meetingLink: link,
                                                                   displayName: displayName))
                }
            }
        } else {
            showError(for: DemoError.invalidToken.getErrorCode())
            return
        }
    }

    private func getTokenCredential() throws -> CommunicationTokenCredential {
        switch selectedAcsTokenType {
        case .token:
            if let communicationTokenCredential = try? CommunicationTokenCredential(token: acsToken) {
                return communicationTokenCredential
            } else {
                throw DemoError.invalidToken
            }
        case .tokenUrl:
            if let url = URL(string: acsTokenUrl) {
                let communicationTokenRefreshOptions = CommunicationTokenRefreshOptions(initialToken: nil, refreshProactively: true, tokenRefresher: AuthenticationHelper.getCommunicationToken(tokenUrl: url))
                if let communicationTokenCredential = try? CommunicationTokenCredential(withOptions: communicationTokenRefreshOptions) {
                    return communicationTokenCredential
                }
            }
            throw DemoError.invalidToken
        }
    }

    private func getMeetingLink() -> String {
        switch selectedMeetingType {
        case .groupCall:
            return groupCallId
        case .teamsMeeting:
            return teamsMeetingLink
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

    func didFail(_ error: ErrorEvent) {
        print("SwiftUIDemoView::getEventsHandler::didFail \(error)")
        print("SwiftUIDemoView error.code \(error.code)")
        showError(for: error.code)
    }
}

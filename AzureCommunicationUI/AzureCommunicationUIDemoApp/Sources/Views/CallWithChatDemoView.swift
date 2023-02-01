//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CallWithChatDemoView: View {
    @ObservedObject var viewModel: CallWithChatDemoViewModel

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
        .alert(isPresented: $viewModel.isErrorDisplayed) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton:
                        .default(Text("Dismiss"), action: {
                            viewModel.hideError()
                        }))
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
            Picker("Token Type", selection: $viewModel.envConfigSubject.selectedAcsTokenType) {
                Text("Token URL").tag(ACSTokenType.tokenUrl)
                Text("Token").tag(ACSTokenType.token)
            }.pickerStyle(.segmented)
            switch viewModel.envConfigSubject.selectedAcsTokenType {
            case .tokenUrl:
                TextField("ACS Token URL", text: $viewModel.envConfigSubject.acsTokenUrl)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
            case .token:
                TextField("ACS Token", text:
                            !viewModel.envConfigSubject.useExpiredToken ?
                          $viewModel.envConfigSubject.acsToken : $viewModel.envConfigSubject.expiredAcsToken)
                .modifier(TextFieldClearButton(text: $viewModel.envConfigSubject.acsToken))
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
        TextField("Display Name", text: $viewModel.envConfigSubject.displayName)
            .disableAutocorrection(true)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .textFieldStyle(.roundedBorder)
    }

    var userIdField: some View {
        TextField("Communication User Id", text: $viewModel.envConfigSubject.userId)
            .disableAutocorrection(true)
            .textFieldStyle(.roundedBorder)
    }

    var endpointUrlField: some View {
        TextField("ACS Endpoint Url", text: $viewModel.envConfigSubject.endpointUrl)
            .disableAutocorrection(true)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .textFieldStyle(.roundedBorder)
    }

    var meetingSelector: some View {
        Group {
            Picker("Call Type", selection: $viewModel.envConfigSubject.selectedMeetingType) {
                Text("Group Call with Chat").tag(MeetingType.groupCall)
                Text("Teams Meeting").tag(MeetingType.teamsMeeting)
            }.pickerStyle(.segmented)
            switch viewModel.envConfigSubject.selectedMeetingType {
            case .groupCall:
                TextField(
                    "Group Call Id",
                    text: $viewModel.envConfigSubject.groupCallId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                TextField(
                    "Group Chat ThreadId",
                    text: $viewModel.envConfigSubject.threadId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
            case .teamsMeeting:
                TextField(
                    "Teams Meeting",
                    text: $viewModel.envConfigSubject.teamsMeetingLink)
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
            viewModel.startExperience()
        }
        .buttonStyle(DemoButtonStyle())
        .disabled(viewModel.isStartExperienceDisabled || viewModel.isStartExperienceLoading)
        .accessibility(identifier: AccessibilityId.startExperienceAccessibilityID.rawValue)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

struct UITestSettingsView: View {
    @ObservedObject var viewModel: UITestSettingsOverlayViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("UITest - Settings")
                .font(Fonts.button2Accessibility.font)
            VStack(alignment: .leading, spacing: 8) {
                Button("simulateCallOnHold") {
                    viewModel.action(.callingAction(.holdRequested))
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateCallOnHold.rawValue)
                Button("simulateCallResume") {
                    viewModel.action(.callingAction(.resumeRequested))
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateCallOnResume.rawValue)
                Button("simulateRecordingStart") {
                    viewModel.action(.callingAction(
                        .recordingStateUpdated(isRecordingActive: true)))
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateRecordingStart.rawValue)
                Button("simulateRecordingEnd") {
                    viewModel.action(.callingAction(
                        .recordingStateUpdated(isRecordingActive: false)))
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateRecordingEnd.rawValue)
                Button("simulateTranscriptionStart") {
                    viewModel.action(.callingAction(
                        .transcriptionStateUpdated(isTranscriptionActive: true)))
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateTranscriptionStart.rawValue)
                Button("simulateTranscriptionEnd") {
                    viewModel.action(.callingAction(
                        .transcriptionStateUpdated(isTranscriptionActive: false)))
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateTranscriptionEnd.rawValue)
                Button("simulateNewParticipantJoin") {
                    let infoModel = ParticipantInfoModel(displayName: "New User 1",
                                                         isSpeaking: false,
                                                         isMuted: true,
                                                         isRemoteUser: true,
                                                         userIdentifier: "userIdentifier1",
                                                         status: .connected,
                                                         recentSpeakingStamp: Date(),
                                                         screenShareVideoStreamModel: nil,
                                                         cameraVideoStreamModel: nil)
                    let infoModel2 = ParticipantInfoModel(displayName: "New User 2",
                                                         isSpeaking: false,
                                                         isMuted: true,
                                                         isRemoteUser: true,
                                                         userIdentifier: "userIdentifier2",
                                                         status: .connected,
                                                         recentSpeakingStamp: Date(),
                                                         screenShareVideoStreamModel: nil,
                                                         cameraVideoStreamModel: nil)
                    let infoModel3 = ParticipantInfoModel(displayName: "New User 3",
                                                         isSpeaking: false,
                                                         isMuted: true,
                                                         isRemoteUser: true,
                                                          userIdentifier: "userIdentifier3",
                                                         status: .connected,
                                                         recentSpeakingStamp: Date(),
                                                         screenShareVideoStreamModel: nil,
                                                         cameraVideoStreamModel: nil)
                    viewModel.action(.callingAction(.participantListUpdated(participants:
                                                                                [infoModel, infoModel2, infoModel3])))
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateNewParticipantJoin.rawValue)
            }
        }
        .padding(.all)
        .background(Color(StyleProvider.color.backgroundColor))
        .opacity(0.7)
    }
}

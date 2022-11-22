//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

struct UITestSettingsView: View {
    @ObservedObject var viewModel: UITestSettingsOverlayViewModel
    @Binding var displayed: Bool

    private enum Constants {
        static let shapeCornerRadius: CGFloat = 5.0
        static let verticalSpacingMedium: CGFloat = 8.0
        static let verticalSpacingLarge: CGFloat = 10.0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.verticalSpacingLarge) {
            Text("UITest - Settings")
                .font(Fonts.button2Accessibility.font)
            VStack(alignment: .leading, spacing: Constants.verticalSpacingMedium) {
                Button("Simulate call on hold") {
                    viewModel.action(.callingAction(.holdRequested))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateCallOnHold.rawValue)
                Button("Simulate call resume") {
                    viewModel.action(.callingAction(.resumeRequested))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateCallOnResume.rawValue)
                Button("Simulate recording start") {
                    viewModel.action(.callingAction(
                        .recordingStateUpdated(isRecordingActive: true)))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateRecordingStart.rawValue)
                Button("Simulate recording end") {
                    viewModel.action(.callingAction(
                        .recordingStateUpdated(isRecordingActive: false)))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateRecordingEnd.rawValue)
                Button("Simulate transcription start") {
                    viewModel.action(.callingAction(
                        .transcriptionStateUpdated(isTranscriptionActive: true)))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateTranscriptionStart.rawValue)
                Button("Simulate transcription end") {
                    viewModel.action(.callingAction(
                        .transcriptionStateUpdated(isTranscriptionActive: false)))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateTranscriptionEnd.rawValue)
                Button("Simulate 1 participants join") {
                    viewModel.addParticipant()
                    viewModel.action(.callingAction(.participantListUpdated(participants:
                                                                                viewModel.participantInfoViewModel)))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulateNewParticipantJoin.rawValue)
                Button("Simulate 3 new participants join") {
                    viewModel.addParticipants(number: 3)
                    viewModel.action(.callingAction(.participantListUpdated(participants:
                                                                                viewModel.participantInfoViewModel)))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulate3NewParticipantJoin.rawValue)
                Button("Simulate 6 participants join") {
                    viewModel.addParticipants(number: 6)
                    viewModel.action(.callingAction(.participantListUpdated(participants:
                                                                                viewModel.participantInfoViewModel)))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulate6NewParticipantJoin.rawValue)
                Button("Simulate 1 participants leave") {
                    viewModel.removeLastPartiicpant()
                    viewModel.action(.callingAction(.participantListUpdated(participants:
                                                                                viewModel.participantInfoViewModel)))
                    displayed = false
                }.accessibilityIdentifier(AccessibilityIdentifier.uitestsimulate1ParticipantLeave.rawValue)
            }
        }
        .padding(.all)
        .background(Color(StyleProvider.color.backgroundColor))
        .opacity(0.7)
        .clipShape(RoundedRectangle(cornerRadius: Constants.shapeCornerRadius))
    }
}

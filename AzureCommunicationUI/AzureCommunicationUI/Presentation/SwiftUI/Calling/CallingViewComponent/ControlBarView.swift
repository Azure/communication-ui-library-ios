//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ControlBarView: View {
    @ObservedObject var viewModel: ControlBarViewModel

    // anchor views for drawer views on (iPad)
    let audioDeviceButtonSourceView = UIView()
    let leaveCallConfirmationListSourceView = UIView()

    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    var body: some View {
        Group {
            if screenSizeClass != .iphoneLandscapeScreenSize {
                HStack {
                    Spacer()
                    videoButton
                    micButton
                    audioDeviceButton
                    hangUpButton
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    hangUpButton
                    audioDeviceButton
                    micButton
                    videoButton
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(StyleProvider.color.backgroundColor))
        .modifier(PopupModalView(isPresented: viewModel.isAudioDeviceSelectionDisplayed) {
            audioDeviceSelectionListView
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
        })
        .modifier(PopupModalView(isPresented: viewModel.isConfirmLeaveListDisplayed) {
            exitConfirmationDrawer
                .accessibility(hidden: !viewModel.isConfirmLeaveListDisplayed)
                .accessibilityElement(children: .contain)
                .accessibility(addTraits: .isModal)
        })
    }

    var videoButton: some View {
        IconButton(viewModel: viewModel.cameraButtonViewModel)
            .accessibility(identifier: LocalizationKey.videoAccessibilityLabel.rawValue)
    }

    var micButton: some View {
        IconButton(viewModel: viewModel.micButtonViewModel)
            .disabled(viewModel.isMicDisabled())
            .accessibility(identifier: LocalizationKey.micAccessibilityLabel.rawValue)
    }

    var audioDeviceButton: some View {
        IconButton(viewModel: viewModel.audioDeviceButtonViewModel)
            .background(SourceViewSpace(sourceView: audioDeviceButtonSourceView))
            .accessibility(identifier: LocalizationKey.audioDeviceAccessibilityLabel.rawValue)

    }

    var hangUpButton: some View {
        IconButton(viewModel: viewModel.hangUpButtonViewModel)
            .background(SourceViewSpace(sourceView: leaveCallConfirmationListSourceView))
            .accessibilityIdentifier(LocalizationKey.hangupAccessibilityLabel.rawValue)
    }

    var audioDeviceSelectionListView: some View {
        CompositeAudioDevicesList(isPresented: $viewModel.isAudioDeviceSelectionDisplayed,
                                  viewModel: viewModel.audioDevicesListViewModel,
                                  sourceView: audioDeviceButtonSourceView)
            .modifier(LockPhoneOrientation())
    }

    var exitConfirmationDrawer: some View {
        CompositeLeaveCallConfirmationList(isPresented: $viewModel.isConfirmLeaveListDisplayed,
                                           viewModel: viewModel.getLeaveCallConfirmationListViewModel(),
                                           sourceView: leaveCallConfirmationListSourceView)
            .modifier(LockPhoneOrientation())
    }
}

struct LeaveCallConfirmationListViewModel {
    let headerName: String?
    let listItemViewModel: [LeaveCallConfirmationViewModel]
}

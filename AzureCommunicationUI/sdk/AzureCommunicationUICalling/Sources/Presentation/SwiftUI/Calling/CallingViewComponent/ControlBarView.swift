//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ControlBarView: View {
    @ObservedObject var viewModel: ControlBarViewModel

    // anchor views for drawer views on (iPad)
    @State var audioDeviceButtonSourceView = UIView()
    @State var moreListSourceView = UIView()
    @State var debugInfoSourceView = UIView()
    @AccessibilityFocusState var focusedOnAudioDeviceButton: Bool
    @AccessibilityFocusState var focusedOnHangUpButton: Bool
    @AccessibilityFocusState var focusedOnMoreButton: Bool
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    var body: some View {
        if viewModel.isDisplayed {
            Group {
                if screenSizeClass == .ipadScreenSize {
                    centeredStack
                } else {
                    nonCenteredStack
                }
            }
            .padding()
            .background(Color(StyleProvider.color.backgroundColor))
            .modifier(PopupModalView(
                isPresented: viewModel.isShareActivityDisplayed) {
                    shareActivityView
                        .accessibilityElement(children: .contain)
                        .accessibilityAddTraits(.isModal)
            })
            .frame(height: 105)
        }
    }

    /// A stack view that has items centered aligned horizontally in its stack view
    var centeredStack: some View {
        Group {
            if screenSizeClass != .iphoneLandscapeScreenSize {
                HStack {
                    Spacer()
                    videoButton
                    micButton
                    audioDeviceButton
                    moreButton
                    hangUpButton
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    hangUpButton
                    moreButton
                    audioDeviceButton
                    micButton
                    videoButton
                    Spacer()
                }
            }
        }
    }

    /// A stack view that has items that take the stackview space evenly
    var nonCenteredStack: some View {
        Group {
            if screenSizeClass != .iphoneLandscapeScreenSize {
                HStack {
                    if viewModel.isCameraDisplayed {
                        videoButton
                        Spacer(minLength: 0)
                    }
                    micButton
                    Spacer(minLength: 0)
                    audioDeviceButton
                    Spacer(minLength: 0)
                    moreButton
                    Spacer(minLength: 0)
                    hangUpButton
                }
            } else {
                VStack {
                    hangUpButton
                    Spacer(minLength: 0)
                    moreButton
                    Spacer(minLength: 0)
                    audioDeviceButton
                    Spacer(minLength: 0)
                    micButton
                    if viewModel.isCameraDisplayed {
                        Spacer(minLength: 0)
                        videoButton
                    }
                }
            }
        }
    }

    var videoButton: some View {
        IconButton(viewModel: viewModel.cameraButtonViewModel)
            .accessibility(identifier: AccessibilityIdentifier.videoAccessibilityID.rawValue)
    }

    var micButton: some View {
        IconButton(viewModel: viewModel.micButtonViewModel)
            .disabled(viewModel.isMicDisabled())
            .accessibility(identifier: AccessibilityIdentifier.micAccessibilityID.rawValue)
    }

    var audioDeviceButton: some View {
        IconButton(viewModel: viewModel.audioDeviceButtonViewModel)
            .background(SourceViewSpace(sourceView: audioDeviceButtonSourceView))
            .accessibility(identifier: AccessibilityIdentifier.audioDeviceAccessibilityID.rawValue)
            .accessibilityFocused($focusedOnAudioDeviceButton, equals: true)

    }

    var hangUpButton: some View {
        IconButton(viewModel: viewModel.hangUpButtonViewModel)
            .accessibilityIdentifier(AccessibilityIdentifier.hangupAccessibilityID.rawValue)
            .accessibilityFocused($focusedOnHangUpButton, equals: true)
    }

    var moreButton: some View {
        IconButton(viewModel: viewModel.moreButtonViewModel)
            .background(SourceViewSpace(sourceView: moreListSourceView))
            .background(SourceViewSpace(sourceView: debugInfoSourceView))
            .accessibilityIdentifier(AccessibilityIdentifier.moreAccessibilityID.rawValue)
            .accessibilityFocused($focusedOnMoreButton, equals: true)
    }

    var shareActivityView: some View {
        return Group {
            SharingActivityView(viewModel: viewModel.debugInfoSharingActivityViewModel,
                                applicationActivities: nil,
                                sourceView: debugInfoSourceView,
                                isPresented: $viewModel.isShareActivityDisplayed)
            .edgesIgnoringSafeArea(.all)
            .modifier(LockPhoneOrientation())
        }
    }
}

struct LeaveCallConfirmationListViewModel {
    let headerName: String
    let listItemViewModel: [DrawerGenericItemViewModel]
}

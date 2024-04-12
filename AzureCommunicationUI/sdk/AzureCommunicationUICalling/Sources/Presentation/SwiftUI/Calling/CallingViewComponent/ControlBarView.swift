//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ControlBarView: View {
    @ObservedObject var viewModel: ControlBarViewModel

    // anchor views for drawer views on (iPad)
    @State var audioDeviceButtonSourceView = UIView()
    @State var leaveCallConfirmationListSourceView = UIView()
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
            .modifier(PopupModalView(isPresented: viewModel.isMoreCallOptionsListDisplayed) {
                moreCallOptionsList
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isModal)
            })
            .modifier(PopupModalView(
                isPresented: !viewModel.isMoreCallOptionsListDisplayed && viewModel.isShareActivityDisplayed) {
                    shareActivityView
                        .accessibilityElement(children: .contain)
                        .accessibilityAddTraits(.isModal)
            })
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
            .background(SourceViewSpace(sourceView: leaveCallConfirmationListSourceView))
            .accessibilityIdentifier(AccessibilityIdentifier.hangupAccessibilityID.rawValue)
            .accessibilityFocused($focusedOnHangUpButton, equals: true)
    }

    var audioDeviceSelectionListView: some View {
        CompositeAudioDevicesList(isPresented: $viewModel.isAudioDeviceSelectionDisplayed,
                                  viewModel: viewModel.audioDevicesListViewModel,
                                  sourceView: audioDeviceButtonSourceView)
        .modifier(LockPhoneOrientation())
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                focusedOnAudioDeviceButton = true
            }
        }
    }

    var exitConfirmationDrawer: some View {
        CompositeLeaveCallConfirmationList(isPresented: $viewModel.isConfirmLeaveListDisplayed,
                                           viewModel: viewModel.getLeaveCallConfirmationListViewModel(),
                                           sourceView: leaveCallConfirmationListSourceView)
        .modifier(LockPhoneOrientation())
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                focusedOnHangUpButton = true
            }
        }
    }

    var moreButton: some View {
        IconButton(viewModel: viewModel.moreButtonViewModel)
            .background(SourceViewSpace(sourceView: moreListSourceView))
            .background(SourceViewSpace(sourceView: debugInfoSourceView))
            .accessibilityIdentifier(AccessibilityIdentifier.moreAccessibilityID.rawValue)
            .accessibilityFocused($focusedOnMoreButton, equals: true)
    }

    var moreCallOptionsList: some View {
        return Group {
            MoreCallOptionsList(isPresented: $viewModel.isMoreCallOptionsListDisplayed,
                                viewModel: viewModel.moreCallOptionsListViewModel,
                                sourceView: moreListSourceView)
            .modifier(LockPhoneOrientation())
            .onDisappear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    focusedOnMoreButton = true
                }
            }
        }
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
    let listItemViewModel: [DrawerListItemViewModel]
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import Combine
import FluentUI

struct SetupView: View {
    @ObservedObject var viewModel: SetupViewModel
    let localPersonaData: CommunicationUIPersonaData?
    let viewManager: VideoViewManager
    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation

    let layoutSpacing: CGFloat = 24
    var horizontalPadding: CGFloat {
        let isIpad = getSizeClass() == .ipadScreenSize
        let isLandscape = orientation.isLandscape
        return isIpad ? (isLandscape ? 360 : 200 ) : 0
    }
    var verticalPadding: CGFloat {
        let isIpad = getSizeClass() == .ipadScreenSize
        let isLandscape = orientation.isLandscape
        return isIpad ? (isLandscape ? 180 : 280 ) : 0
    }
    let startCallButtonHeight: CGFloat = 52
    let errorHorizontalPadding: CGFloat = 8

    var body: some View {
        ZStack {
            VStack(spacing: layoutSpacing) {
                SetupTitleView(viewModel: viewModel)
                VStack(spacing: layoutSpacing) {
                    ZStack(alignment: .bottom) {
                        PreviewAreaView(viewModel: viewModel.previewAreaViewModel,
                                        localPersonaData: localPersonaData,
                                        viewManager: viewManager)
                        SetupControlBarView(viewModel: viewModel.setupControlBarViewModel)
                    }
                    .background(Color(StyleProvider.color.surface))
                    .cornerRadius(4)
                    joinCallView
                        .padding(.bottom)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
            }
            errorInfoView
        }
        .onAppear {
            viewModel.setupAudioPermissions()
            viewModel.setupCall()
        }
        .onRotate { newOrientation in
            if newOrientation != orientation
                && newOrientation != .unknown
                && newOrientation != .faceDown
                && newOrientation != .faceUp {
                orientation = newOrientation
            }
        }
    }

    var joinCallView: some View {
        Group {
            if viewModel.isJoinRequested {
                JoiningCallActivityView(viewModel: viewModel.joiningCallActivityViewModel)
            } else {
                PrimaryButton(viewModel: viewModel.joinCallButtonViewModel)
                    .accessibilityIdentifier(AccessibilityIdentifier.joinCallAccessibilityID.rawValue)
            }
        }
    }

    var errorInfoView: some View {
        VStack {
            Spacer()
            ErrorInfoView(viewModel: viewModel.errorInfoViewModel)
                .padding(EdgeInsets(top: 0,
                                    leading: errorHorizontalPadding,
                                    bottom: startCallButtonHeight + layoutSpacing,
                                    trailing: errorHorizontalPadding)
                )
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
        }
    }
    
    private func getSizeClass() -> ScreenSizeClassType {
        switch (widthSizeClass, heightSizeClass) {
        case (.compact, .regular):
            return .iphonePortraitScreenSize
        case (.compact, .compact),
             (.regular, .compact):
            return .iphoneLandscapeScreenSize
        default:
            return .ipadScreenSize
        }
    }
}

struct SetupTitleView: View {
    let viewHeight: CGFloat = 44
    let verticalSpacing: CGFloat = 0
    var viewModel: SetupViewModel

    var body: some View {
        VStack(spacing: verticalSpacing) {
            ZStack(alignment: .leading) {
                IconButton(viewModel: viewModel.dismissButtonViewModel)
                    .flipsForRightToLeftLayoutDirection(true)
                HStack {
                    Spacer()
                    Text(viewModel.title)
                        .font(Fonts.headline.font)
                        .foregroundColor(Color(StyleProvider.color.onBackground))
                        .accessibilityAddTraits(.isHeader)
                    Spacer()
                }.accessibilitySortPriority(1)
            }.frame(height: viewHeight)
            Divider()
        }
    }
}

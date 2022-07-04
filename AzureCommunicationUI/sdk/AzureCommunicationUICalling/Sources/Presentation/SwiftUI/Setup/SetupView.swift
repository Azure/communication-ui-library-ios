//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import Combine
import FluentUI

struct SetupView: View {
    @ObservedObject var viewModel: SetupViewModel
    let viewManager: VideoViewManager
    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?
    @Orientation var orientation: UIDeviceOrientation
    let avatarManager: AvatarViewManager

    let layoutSpacing: CGFloat = 24
    let layoutSpacingLarge: CGFloat = 40
    let startCallButtonHeight: CGFloat = 52
    let errorHorizontalPadding: CGFloat = 8
    private let setupViewiPadLarge: CGFloat = 469.0
    private let setupViewiPadSmall: CGFloat = 375.0

    var body: some View {
        ZStack {
            VStack(spacing: layoutSpacing) {
                SetupTitleView(viewModel: viewModel)
                GeometryReader { geometry in
                    ZStack(alignment: .bottomLeading) {
                        VStack(spacing: getSizeClass() == .ipadScreenSize ? layoutSpacingLarge : layoutSpacing) {
                            ZStack(alignment: .bottom) {
                                PreviewAreaView(viewModel: viewModel.previewAreaViewModel,
                                                viewManager: viewManager,
                                                avatarManager: avatarManager)
                                SetupControlBarView(viewModel: viewModel.setupControlBarViewModel)
                            }
                            .background(Color(StyleProvider.color.surface))
                            .cornerRadius(4)
                            joinCallView
                                .padding(.bottom)
                        }
                        .padding(.vertical, setupViewVerticalPadding(parentSize: geometry.size))
                        errorInfoView
                            .padding(.bottom, setupViewVerticalPadding(parentSize: geometry.size))
                    }
                    .padding(.horizontal, setupViewHorizontalPadding(parentSize: geometry.size))
                }
            }
        }
        .onAppear {
            viewModel.setupAudioPermissions()
            viewModel.setupCall()
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

    private func setupViewHorizontalPadding(parentSize: CGSize) -> CGFloat {
        let isIpad = getSizeClass() == .ipadScreenSize
        guard isIpad else {
            return 16
        }
        let isLandscape = orientation.isLandscape
        let horizontalPadding = (parentSize.width - (isLandscape ? setupViewiPadLarge : setupViewiPadSmall)) / 2.0
        return horizontalPadding
    }

    private func setupViewVerticalPadding(parentSize: CGSize) -> CGFloat {
        let isIpad = getSizeClass() == .ipadScreenSize
        guard isIpad else {
            return 16
        }
        let isLandscape = orientation.isLandscape
        let setupViewiPadSmallHeightWithMargin = setupViewiPadSmall + layoutSpacingLarge + startCallButtonHeight
        let setupViewiPadLargeHeightWithMargin = setupViewiPadLarge + layoutSpacingLarge + startCallButtonHeight
        let verticalPadding = (parentSize.height - (isLandscape ?
                                                    setupViewiPadSmallHeightWithMargin
                                                    : setupViewiPadLargeHeightWithMargin)) / 2.0
        return verticalPadding
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
                    .accessibilityIdentifier(AccessibilityIdentifier.dismisButtonAccessibilityID.rawValue)
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

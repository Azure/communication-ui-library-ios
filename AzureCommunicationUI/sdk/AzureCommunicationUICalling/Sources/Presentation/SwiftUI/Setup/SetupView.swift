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
    let avatarManager: AvatarViewManagerProtocol

    enum LayoutConstant {
        static let spacing: CGFloat = 24
        static let spacingLarge: CGFloat = 40
        static let startCallButtonHeight: CGFloat = 52
        static let iPadLarge: CGFloat = 469.0
        static let iPadSmall: CGFloat = 375.0
        static let iPadSmallHeightWithMargin: CGFloat = iPadSmall + spacingLarge + startCallButtonHeight
        static let iPadLargeHeightWithMargin: CGFloat = iPadLarge + spacingLarge + startCallButtonHeight
    }

    var body: some View {
        ZStack {
            VStack(spacing: LayoutConstant.spacing) {
                SetupTitleView(viewModel: viewModel)
                GeometryReader { geometry in
                    ZStack(alignment: .bottomLeading) {
                        VStack(alignment: .center,
                               spacing: getSizeClass() == .ipadScreenSize ?
                               LayoutConstant.spacingLarge : LayoutConstant.spacing) {
                            ZStack(alignment: .center) {
                                PreviewAreaView(viewModel: viewModel.previewAreaViewModel,
                                                viewManager: viewManager,
                                                avatarManager: avatarManager)
                                if viewModel.shouldShowSetupControlBarView() {
                                    SetupControlBarView(viewModel: viewModel.setupControlBarViewModel)
                                }
                            }
                            .background(Color(StyleProvider.color.surface))
                            .cornerRadius(4)
                            .accessibilityElement(children: .contain)
                            joinCallView
                                .padding(.bottom)
                        }
                        .padding(.vertical, setupViewVerticalPadding(parentSize: geometry.size))
                        errorInfoView
                            .padding(.bottom, setupViewVerticalPadding(parentSize: geometry.size))
                    }
                    .padding(.horizontal, setupViewHorizontalPadding(parentSize: geometry.size))
                    .accessibilityElement(children: .contain)
                }
            }
        }
    }

    var joinCallView: some View {
        Group {
            if viewModel.isJoinRequested {
                JoiningCallActivityView(viewModel: viewModel.joiningCallActivityViewModel)
            } else {
                PrimaryButton(viewModel: viewModel.joinCallButtonViewModel)
                    .frame(height: 52)
                    .accessibilityIdentifier(AccessibilityIdentifier.joinCallAccessibilityID.rawValue)
            }
        }
    }

    var errorInfoView: some View {
        VStack {
            Spacer()
            ErrorInfoView(viewModel: viewModel.errorInfoViewModel)
                .padding(EdgeInsets(top: 0,
                                    leading: 0,
                                    bottom: LayoutConstant.startCallButtonHeight + LayoutConstant.spacing,
                                    trailing: 0)
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
        let screenSize = isLandscape ? LayoutConstant.iPadLarge : LayoutConstant.iPadSmall
        let horizontalPadding = (parentSize.width - screenSize) / 2.0
        return horizontalPadding
    }

    private func setupViewVerticalPadding(parentSize: CGSize) -> CGFloat {
        let isIpad = getSizeClass() == .ipadScreenSize
        guard isIpad else {
            return 16
        }
        let isLandscape = orientation.isLandscape
        let verticalPadding = (parentSize.height - (isLandscape ?
                                                    LayoutConstant.iPadSmallHeightWithMargin
                                                    : LayoutConstant.iPadLargeHeightWithMargin)) / 2.0
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
    let padding: CGFloat = 34.0
    let verticalSpacing: CGFloat = 0
    var viewModel: SetupViewModel

    @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

    var body: some View {
        VStack(spacing: verticalSpacing) {
            ZStack(alignment: .leading) {
                IconButton(viewModel: viewModel.dismissButtonViewModel)
                    .flipsForRightToLeftLayoutDirection(true)
                    .accessibilityIdentifier(AccessibilityIdentifier.dismissButtonAccessibilityID.rawValue)
                HStack {
                    Spacer()
                    VStack {
                        Text(viewModel.title)
                            .font(Fonts.headline.font)
                            .foregroundColor(Color(StyleProvider.color.onBackground))
                            .lineLimit(1)
                            .minimumScaleFactor(sizeCategory.isAccessibilityCategory ? 0.4 : 1)
                            .accessibilityAddTraits(.isHeader)
                        if let subtitle = viewModel.subTitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(Fonts.caption1.font)
                                .foregroundColor(Color(StyleProvider.color.onNavigationSecondary))
                                .lineLimit(1)
                                .minimumScaleFactor(sizeCategory.isAccessibilityCategory ? 0.4 : 1)
                                .accessibilityAddTraits(.isHeader)
                        }
                    }
                    Spacer()
                }.accessibilitySortPriority(1)
                 .padding(padding)
            }.frame(height: viewHeight)
            Divider()
        }
    }
}

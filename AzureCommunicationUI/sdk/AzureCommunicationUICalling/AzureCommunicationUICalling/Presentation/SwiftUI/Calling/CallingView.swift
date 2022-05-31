//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CallingView: View {

    struct Constants {
        static let infoHeaderViewHorizontalPadding: CGFloat = 8.0
        static let infoHeaderViewMaxWidth: CGFloat = 380.0
        static let infoHeaderViewHeight: CGFloat = 46.0
    }

    @ObservedObject var viewModel: CallingViewModel
    let avatarManager: AvatarViewManager
    let viewManager: VideoViewManager
    let leaveCallConfirmationListSourceView = UIView()

    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation

    var safeAreaIgnoreArea: Edge.Set {
        return getSizeClass() != .iphoneLandscapeScreenSize ? []: [.bottom]
    }

    var body: some View {
        ZStack {
            if getSizeClass() != .iphoneLandscapeScreenSize {
                portraitCallingView
            } else {
                landscapeCallingView
            }
        }
        .environment(\.screenSizeClass, getSizeClass())
        .environment(\.appPhase, viewModel.appState)
        .edgesIgnoringSafeArea(safeAreaIgnoreArea)
        .onRotate { newOrientation in
            updateChildViewIfNeededWith(newOrientation: newOrientation)
        }
    }

    var portraitCallingView: some View {
        VStack(alignment: .center, spacing: 0) {
            containerView
            controlBarView
        }
    }

    var landscapeCallingView: some View {
        HStack(alignment: .center, spacing: 0) {
            containerView
            controlBarView
        }
    }

    var containerView: some View {
        Group {
            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing) {
                    videoGridView
                        .accessibilityHidden(!viewModel.isVideoGridViewAccessibilityAvailable)
                    if viewModel.isParticipantGridDisplayed {
                        Group {
                            DraggableLocalVideoView(containerBounds:
                                                        geometry.frame(in: .local),
                                                    viewModel: viewModel,
                                                    avatarManager: avatarManager,
                                                    viewManager: viewManager,
                                                    orientation: $orientation,
                                                    screenSize: getSizeClass())
                        }
                    }
                    topAlertAreaView
                        .accessibilityElement(children: .contain)
                        .accessibilitySortPriority(1)
                        .accessibilityHidden(viewModel.isLobbyOverlayDisplayed)
                }
                .contentShape(Rectangle())
                .animation(.linear(duration: 0.167))
                .onTapGesture(perform: {
                    viewModel.infoHeaderViewModel.toggleDisplayInfoHeaderIfNeeded()
                })
                .modifier(PopupModalView(isPresented: viewModel.isLobbyOverlayDisplayed) {
                    LobbyOverlayView(viewModel: viewModel.getLobbyOverlayViewModel())
                        .accessibilityElement(children: .contain)
                        .accessibilityHidden(!viewModel.isLobbyOverlayDisplayed)
                })
            }
        }
    }

    var topAlertAreaView: some View {
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let isIpad = getSizeClass() == .ipadScreenSize
            let widthWithoutHorizontalPadding = geoWidth - 2 * Constants.infoHeaderViewHorizontalPadding
            let infoHeaderViewWidth = isIpad ? min(widthWithoutHorizontalPadding,
                                                   Constants.infoHeaderViewMaxWidth) : widthWithoutHorizontalPadding
            VStack {
                bannerView
                HStack {
                    if isIpad {
                        Spacer()
                    } else {
                        EmptyView()
                    }
                    infoHeaderView
                        .frame(width: infoHeaderViewWidth, height: Constants.infoHeaderViewHeight, alignment: .leading)
                        .padding(.horizontal, Constants.infoHeaderViewHorizontalPadding)
                    Spacer()
                }
                Spacer()
            }
        }
    }

    var infoHeaderView: some View {
        InfoHeaderView(viewModel: viewModel.infoHeaderViewModel,
                       avatarViewManager: avatarManager)
    }

    var bannerView: some View {
        BannerView(viewModel: viewModel.bannerViewModel)
    }

    var participantGridsView: some View {
        ParticipantGridView(viewModel: viewModel.participantGridsViewModel,
                            avatarViewManager: avatarManager,
                            videoViewManager: viewManager,
                            screenSize: getSizeClass())
            .edgesIgnoringSafeArea(safeAreaIgnoreArea)
    }

    var localVideoFullscreenView: some View {
        return Group {
            LocalVideoView(viewModel: viewModel.localVideoViewModel,
                           viewManager: viewManager,
                           viewType: .localVideofull,
                           avatarManager: avatarManager)
                .background(Color(StyleProvider.color.surface))
                .edgesIgnoringSafeArea(safeAreaIgnoreArea)
        }
    }

    var videoGridView: some View {
        Group {
            if viewModel.isParticipantGridDisplayed {
                participantGridsView
            } else {
                localVideoFullscreenView
            }
        }
    }

    var controlBarView: some View {
        ControlBarView(viewModel: viewModel.controlBarViewModel)
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

    private func updateChildViewIfNeededWith(newOrientation: UIDeviceOrientation) {
        if newOrientation != orientation
            && newOrientation != .unknown
            && newOrientation != .faceDown
            && newOrientation != .faceUp {
            orientation = newOrientation
        }
    }
}

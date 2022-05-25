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
    @State private var pipPosition: CGPoint?
    @GestureState private var pipDragStartPosition: CGPoint?

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
            if newOrientation != orientation
                && newOrientation != .unknown
                && newOrientation != .faceDown
                && newOrientation != .faceUp {
                orientation = newOrientation
            }
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
                        draggableVideoPipView
                    }
                    topAlertAreaView
                        .accessibilityElement(children: .contain)
                        .accessibilitySortPriority(1)
                        .accessibilityHidden(viewModel.isLobbyOverlayDisplayed)
                }
                .onAppear {
                    self.pipPosition = getInitialPipPosition(containerBounds: geometry.frame(in: .local))
                }
                .onChange(of: geometry.size) { _ in
                    self.pipPosition = getInitialPipPosition(containerBounds: geometry.frame(in: .local))
                }
                .onChange(of: orientation) { _ in
                    self.pipPosition = getInitialPipPosition(containerBounds: geometry.frame(in: .local))
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

    var draggableVideoPipView: some View {
        return Group {
            if self.pipPosition != nil {
                DraggableLocalVideoView(viewModel: viewModel,
                                        avatarManager: avatarManager,
                                        viewManager: viewManager,
                                        pipPosition: $pipPosition)
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

    private func getInitialPipPosition(containerBounds: CGRect) -> CGPoint {
        return CGPoint(
            x: getContainerBounds(bounds: containerBounds).maxX,
            y: getContainerBounds(bounds: containerBounds).maxY)
    }

    private func getContainerBounds(bounds: CGRect) -> CGRect {
        let pipSize = getPipSize(parentSize: bounds.size)
        let isiPad = getSizeClass() == .ipadScreenSize
        let padding = isiPad ? 8.0 : 12.0
        let containerBounds = bounds.inset(by: UIEdgeInsets(
            top: pipSize.height / 2.0 + padding,
            left: pipSize.width / 2.0 + padding,
            bottom: pipSize.height / 2.0 + padding,
            right: pipSize.width / 2.0 + padding))
        return containerBounds
    }

    private func getPipSize(parentSize: CGSize? = nil) -> CGSize {
        let isPortraitMode = getSizeClass() != .iphoneLandscapeScreenSize
        let isiPad = getSizeClass() == .ipadScreenSize

        func defaultSize() -> CGSize {
            let width = isPortraitMode ? 72 : 104
            let height = isPortraitMode ? 104 : 72
            let size = CGSize(width: width, height: height)
            return size
        }

        if isiPad {
            if let parentSize = parentSize {
                if parentSize.width < parentSize.height {
                    // portrait
                    return CGSize(width: 80.0, height: 115.0)
                } else {
                    // landscape
                    return CGSize(width: 152.0, height: 115.0)
                }
            }
        }

        return defaultSize()
    }
}

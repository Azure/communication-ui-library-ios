//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CallingView: View {
    @ObservedObject var viewModel: CallingViewModel
    let avatarManager: AvatarViewManagerProtocol
    let viewManager: VideoViewManager

    let leaveCallConfirmationListSourceView = UIView()

    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var pipPosition: CGPoint?
    @GestureState private var startLocation: CGPoint?

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
                    if self.pipPosition == nil {
                        self.pipPosition = getInitialPipPosition(containerBounds: geometry.frame(in: .local))
                    }
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

    var localVideoPipView: some View {
        let shapeCornerRadius: CGFloat = 4
        let size = getPipSize()

        return Group {
            LocalVideoView(viewModel: viewModel.localVideoViewModel,
                           personaData: avatarManager.getLocalPersonaData(),
                           viewManager: viewManager,
                           viewType: .localVideoPip)
                .frame(width: size.width, height: size.height, alignment: .center)
                .background(Color(StyleProvider.color.backgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: shapeCornerRadius))
                .padding()
        }
    }

    var draggableVideoPipView: some View {
        return Group {
            if self.pipPosition != nil {
                GeometryReader { geometry in
                    localVideoPipView
                        .position(self.pipPosition!)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let containerBounds = getContainerBounds(bounds: geometry.frame(in: .local))
                                    print("Pip Position: \(self.pipPosition)")
                                    print("Bounds: \(containerBounds)")
                                    print("Drag Position: \(value.location)")
                                    print("Drag Translation: \(value.translation)")
                                    var flippedLocation = self.startLocation ?? self.pipPosition!
                                    flippedLocation.x += viewModel.isRightToLeft
                                    ? -value.translation.width
                                    : value.translation.width
                                    flippedLocation.y += value.translation.height
//                                    transformEffect(CGAffineTransform()
//                                    self.pipPosition = getBoundedPipPosition(
//                                        currentPipPosition: self.pipPosition!,
//                                        requestedPipPosition: value.location,
//                                        bounds: containerBounds)
                                    self.pipPosition = getBoundedPipPosition(
                                        currentPipPosition: self.pipPosition!,
                                        requestedPipPosition: flippedLocation,
                                        bounds: containerBounds)
                                    print("New Position: \(self.pipPosition)")
                                }
                                .updating($startLocation) { (_, startLocation, _) in
                                    startLocation = startLocation ?? self.pipPosition
                                }
                        )
                }
            }
        }
    }

    var topAlertAreaView: some View {
        VStack {
            bannerView
            infoHeaderView
                .padding(.horizontal, 8)
            Spacer()
        }
    }

    var infoHeaderView: some View {
        InfoHeaderView(viewModel: viewModel.infoHeaderViewModel)
    }

    var bannerView: some View {
        BannerView(viewModel: viewModel.bannerViewModel)
    }

    var participantGridsView: some View {
        ParticipantGridView(viewModel: viewModel.participantGridsViewModel,
                            videoViewManager: viewManager,
                            screenSize: getSizeClass())
            .edgesIgnoringSafeArea(safeAreaIgnoreArea)
    }

    var localVideoFullscreenView: some View {
        return Group {
            LocalVideoView(viewModel: viewModel.localVideoViewModel,
                           personaData: avatarManager.getLocalPersonaData(),
                           viewManager: viewManager,
                           viewType: .localVideofull)
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
        let pipSize = getPipSize()
        let padding = 12.0
        return bounds.inset(by: UIEdgeInsets(
                top: pipSize.height / 2.0 + padding,
                left: pipSize.width / 2.0 + padding,
                bottom: pipSize.height / 2.0 + padding,
                right: pipSize.width / 2.0 + padding))
    }

    private func getBoundedPipPosition(
        currentPipPosition: CGPoint,
        requestedPipPosition: CGPoint,
        bounds: CGRect) -> CGPoint {
        var boundedPipPosition = currentPipPosition

        if bounds.contains(requestedPipPosition) {
            boundedPipPosition = requestedPipPosition
        } else if requestedPipPosition.x > bounds.minX && requestedPipPosition.x < bounds.maxX {
            boundedPipPosition.x = requestedPipPosition.x
            boundedPipPosition.y = getMinMaxLimitedValue(
                value: requestedPipPosition.y,
                min: bounds.minY,
                max: bounds.maxY)
        } else if requestedPipPosition.y > bounds.minY && requestedPipPosition.y < bounds.maxY {
            boundedPipPosition.x = getMinMaxLimitedValue(
                value: requestedPipPosition.x,
                min: bounds.minX,
                max: bounds.maxX)
            boundedPipPosition.y = requestedPipPosition.y
        }

        return boundedPipPosition
    }

    private func getPipSize() -> CGSize {
        let isPortraitMode = getSizeClass() != .iphoneLandscapeScreenSize
        let width = isPortraitMode ? 72 : 104
        let height = isPortraitMode ? 104 : 72

        return CGSize(width: width, height: height)
    }

    private func getMinMaxLimitedValue(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        var limitedValue = value
        if value < min {
            limitedValue = min
        } else if value > max {
            limitedValue = max
        }
        return limitedValue
    }
}

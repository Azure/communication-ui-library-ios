//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CallingView: View {
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
            ControlBarView(viewModel: viewModel.controlBarViewModel)
        }
    }

    var landscapeCallingView: some View {
        HStack(alignment: .center, spacing: 0) {
            containerView
            ControlBarView(viewModel: viewModel.controlBarViewModel)
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
                        .accessibilityHidden(viewModel.lobbyOverlayViewModel.isDisplayed)
                    errorInfoView
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
                .modifier(PopupModalView(isPresented: viewModel.lobbyOverlayViewModel.isDisplayed) {
                    OverlayView(viewModel: viewModel.lobbyOverlayViewModel)
                        .accessibilityElement(children: .contain)
                        .accessibilityHidden(!viewModel.lobbyOverlayViewModel.isDisplayed)
                })
                .modifier(PopupModalView(isPresented: viewModel.onHoldOverlayViewModel.isDisplayed) {
                    OverlayView(viewModel: viewModel.onHoldOverlayViewModel)
                        .accessibilityElement(children: .contain)
                        .accessibilityHidden(!viewModel.onHoldOverlayViewModel.isDisplayed)
                })
            }
        }
    }

    var localVideoPipView: some View {
        let shapeCornerRadius: CGFloat = 4
        let size = getPipSize()

        return Group {
            LocalVideoView(viewModel: viewModel.localVideoViewModel,
                           viewManager: viewManager,
                           viewType: .localVideoPip,
                           avatarManager: avatarManager)
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
                                    let translatedPipPosition = getTranslatedPipPosition(
                                        currentPipPosition: self.pipPosition!,
                                        pipDragStartPosition: self.pipDragStartPosition,
                                        translation: value.translation,
                                        isRightToLeft: viewModel.isRightToLeft)
                                    self.pipPosition = getBoundedPipPosition(
                                        currentPipPosition: self.pipPosition!,
                                        requestedPipPosition: translatedPipPosition,
                                        bounds: containerBounds)
                                }
                                .updating($pipDragStartPosition) { (_, startLocation, _) in
                                    startLocation = startLocation ?? self.pipPosition
                                }
                        )
                }
            }
        }
    }

    var topAlertAreaView: some View {
        VStack {
            BannerView(viewModel: viewModel.bannerViewModel)
            InfoHeaderView(viewModel: viewModel.infoHeaderViewModel,
                       avatarViewManager: avatarManager)
                .padding(.horizontal, 8)
            Spacer()
        }
    }

    var errorInfoView: some View {
        VStack {
            Spacer()
            ErrorInfoView(viewModel: viewModel.errorInfoViewModel)
//                .padding(EdgeInsets(top: 0,
//                                    leading: errorHorizontalPadding,
//                                    bottom: startCallButtonHeight + layoutSpacing,
//                                    trailing: errorHorizontalPadding)
//                )
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
        }
    }

    var participantGridsView: some View {
        ParticipantGridView(viewModel: viewModel.participantGridsViewModel,
                            avatarViewManager: avatarManager,
                            videoViewManager: viewManager,
                            screenSize: getSizeClass())
            .edgesIgnoringSafeArea(safeAreaIgnoreArea)
    }

    var localVideoFullscreenView: some View {
        Group {
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
}

extension CallingView {
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

    private func getTranslatedPipPosition(
        currentPipPosition: CGPoint,
        pipDragStartPosition: CGPoint?,
        translation: CGSize,
        isRightToLeft: Bool) -> CGPoint {
        var translatedPipPosition = pipDragStartPosition ?? currentPipPosition

        translatedPipPosition.x += isRightToLeft
        ? -translation.width
        : translation.width
        translatedPipPosition.y += translation.height

        return translatedPipPosition
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

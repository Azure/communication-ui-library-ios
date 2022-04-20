//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CallingView: View {
    @ObservedObject var viewModel: CallingViewModel
    let viewManager: VideoViewManager

    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?

    @State private var pipPosition = CGPoint()
    @State private var pipSize = CGSize()

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
        .modifier(PopupModalView(isPresented: viewModel.isConfirmLeaveOverlayDisplayed) {
            ConfirmLeaveOverlayView(viewModel: viewModel)
                .accessibilityHidden(!viewModel.isConfirmLeaveOverlayDisplayed)
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
        })
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
                        .accessibilityHidden(viewModel.isLobbyOverlayDisplayed)
                    topAlertAreaView
                        .accessibilityElement(children: .contain)
                        .accessibilitySortPriority(1)
                        .accessibilityHidden(viewModel.isLobbyOverlayDisplayed)
                    if viewModel.isParticipantGridDisplayed {
                        draggableVideoPipView
                            .padding(.horizontal, -12)
                            .padding(.vertical, -12)
                            .onAppear {
                                self.pipPosition = getInitialPipPosition(
                                    containerBounds: geometry.frame(in: .local),
                                    pipSize: self.pipSize)
                            }
                    }
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
        let isPortraitMode = getSizeClass() != .iphoneLandscapeScreenSize
        let frameWidth: CGFloat = isPortraitMode ? 72 : 104
        let frameHeight: CGFloat = isPortraitMode ? 104 : 72

        return Group {
            LocalVideoView(viewModel: viewModel.localVideoViewModel,
                           viewManager: viewManager,
                           viewType: .localVideoPip)
                .frame(width: frameWidth, height: frameHeight, alignment: .center)
                .background(Color(StyleProvider.color.backgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: shapeCornerRadius))
                .padding()
        }
    }

    var draggableVideoPipView: some View {
        return Group {
            GeometryReader { geometry in
                localVideoPipView
                    .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { geometry[$0] }
                    .onPreferenceChange(BoundsPreferenceKey.self) {
                        self.pipSize = $0.size
                    }
                    .position(self.pipPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let containerBounds = getContainerBounds(
                                    bounds: geometry.frame(in: .local),
                                    pipSize: self.pipSize)
                                self.pipPosition = getBoundedPipPosition(
                                    currentPipPosition: self.pipPosition,
                                    requestedPipPosition: value.location,
                                    bounds: containerBounds)
                            }
                    )
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

    private func getInitialPipPosition(containerBounds: CGRect, pipSize: CGSize) -> CGPoint {
        return CGPoint(
            x: getContainerBounds(bounds: containerBounds, pipSize: pipSize).maxX,
            y: getContainerBounds(bounds: containerBounds, pipSize: pipSize).maxY)
    }

    private func getRotatedPipPosition(currentPipPosition: CGPoint) -> CGPoint {
        // Calculate new pipPosition after screen rotation
        return currentPipPosition
    }

    private func getContainerBounds(bounds: CGRect, pipSize: CGSize) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(
                top: pipSize.height / 2.0,
                left: pipSize.width / 2.0,
                bottom: pipSize.height / 2.0,
                right: pipSize.width / 2.0))
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

private struct BoundsPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

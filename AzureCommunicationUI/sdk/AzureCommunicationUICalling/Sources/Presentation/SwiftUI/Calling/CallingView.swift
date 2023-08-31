//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CallingView: View {
    enum InfoHeaderViewConstants {
        static let horizontalPadding: CGFloat = 8.0
        static let maxWidth: CGFloat = 380.0
        static let height: CGFloat = 46.0
    }

    enum ErrorInfoConstants {
        static let controlBarHeight: CGFloat = 92
        static let horizontalPadding: CGFloat = 8
    }

    enum DiagnosticInfoConstants {
        static let controlBarHeight: CGFloat = 92
        static let horizontalPadding: CGFloat = 8
    }

    @ObservedObject var viewModel: CallingViewModel
    let avatarManager: AvatarViewManagerProtocol
    let viewManager: VideoViewManager

    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation

    var safeAreaIgnoreArea: Edge.Set {
        return getSizeClass() != .iphoneLandscapeScreenSize ? []: [.bottom]
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if getSizeClass() != .iphoneLandscapeScreenSize {
                    portraitCallingView
                } else {
                    landscapeCallingView
                }
                errorInfoView
                diagnosticsView
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
        }
        .environment(\.screenSizeClass, getSizeClass())
        .environment(\.appPhase, viewModel.appState)
        .edgesIgnoringSafeArea(safeAreaIgnoreArea)
        .onRotate { newOrientation in
            updateChildViewIfNeededWith(newOrientation: newOrientation)
        }.onAppear {
            resetOrientation()
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
                        Group {
                            DraggableLocalVideoView(containerBounds:
                                                        geometry.frame(in: .local),
                                                    viewModel: viewModel,
                                                    avatarManager: avatarManager,
                                                    viewManager: viewManager,
                                                    orientation: $orientation,
                                                    screenSize: getSizeClass())
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier(AccessibilityIdentifier.draggablePipViewAccessibilityID.rawValue)
                    }
                    topAlertAreaView
                        .accessibilityElement(children: .contain)
                        .accessibilitySortPriority(1)
                        .accessibilityHidden(viewModel.lobbyOverlayViewModel.isDisplayed
                                             || viewModel.onHoldOverlayViewModel.isDisplayed
                                             || viewModel.loadingOverlayViewModel.isDisplayed)
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
                .modifier(PopupModalView(isPresented: viewModel.loadingOverlayViewModel.isDisplayed &&
                                         !viewModel.lobbyOverlayViewModel.isDisplayed) {
                    LoadingOverlayView(viewModel: viewModel.loadingOverlayViewModel)
                        .accessibilityElement(children: .contain)
                        .accessibilityHidden(!viewModel.loadingOverlayViewModel.isDisplayed)
                })
                .modifier(PopupModalView(isPresented: viewModel.onHoldOverlayViewModel.isDisplayed) {
                    OverlayView(viewModel: viewModel.onHoldOverlayViewModel)
                        .accessibilityElement(children: .contain)
                        .accessibilityHidden(!viewModel.onHoldOverlayViewModel.isDisplayed)
                })
            }
        }
    }

    var topAlertAreaView: some View {
        GeometryReader { geometry in
            let geoWidth: CGFloat = geometry.size.width
            let isIpad = getSizeClass() == .ipadScreenSize
            let widthWithoutHorizontalPadding = geoWidth - 2 * InfoHeaderViewConstants.horizontalPadding
            let infoHeaderViewWidth = isIpad ? min(widthWithoutHorizontalPadding,
                                                   InfoHeaderViewConstants.maxWidth) : widthWithoutHorizontalPadding
            VStack {
                bannerView
                HStack {
                    if isIpad {
                        Spacer()
                    } else {
                        EmptyView()
                    }
                    infoHeaderView
                        .frame(width: infoHeaderViewWidth, height: InfoHeaderViewConstants.height, alignment: .leading)
                        .padding(.leading, InfoHeaderViewConstants.horizontalPadding)
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

    var errorInfoView: some View {
        return VStack {
            Spacer()
            ErrorInfoView(viewModel: viewModel.errorInfoViewModel)
                .padding(EdgeInsets(top: 0,
                                    leading: ErrorInfoConstants.horizontalPadding,
                                    bottom: ErrorInfoConstants.controlBarHeight,
                                    trailing: ErrorInfoConstants.horizontalPadding)
                )
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
        }
    }

    var diagnosticsView: some View {
        return VStack {
            Spacer()
            UFDInfoView(viewModel: viewModel.ufdInfoViewModel)
                .padding(EdgeInsets(top: 0,
                                    leading: DiagnosticInfoConstants.horizontalPadding,
                                    bottom: DiagnosticInfoConstants.controlBarHeight,
                                    trailing: DiagnosticInfoConstants.horizontalPadding)
                )
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
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

    private func updateChildViewIfNeededWith(newOrientation: UIDeviceOrientation) {
        guard !viewModel.controlBarViewModel.isAudioDeviceSelectionDisplayed,
              !viewModel.controlBarViewModel.isConfirmLeaveListDisplayed,
              !viewModel.infoHeaderViewModel.isParticipantsListDisplayed,
              !viewModel.controlBarViewModel.isMoreCallOptionsListDisplayed,
              !viewModel.controlBarViewModel.isShareActivityDisplayed else {
                return
            }
        let areAllOrientationsSupported = SupportedOrientationsPreferenceKey.defaultValue == .all
        if newOrientation != orientation
            && newOrientation != .unknown
            && newOrientation != .faceDown
            && newOrientation != .faceUp
            && (areAllOrientationsSupported || (!areAllOrientationsSupported
                                                && newOrientation != .portraitUpsideDown)) {
            orientation = newOrientation
            if UIDevice.current.userInterfaceIdiom == .phone {
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }

    private func resetOrientation() {
        UIDevice.current.setValue(UIDevice.current.orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

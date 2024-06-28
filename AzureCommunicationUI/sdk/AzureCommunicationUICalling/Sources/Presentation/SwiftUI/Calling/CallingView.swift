//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// swiftlint:disable type_body_length
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

    enum Constants {
        static let topAlertAreaViewTopPaddin: CGFloat = 10.0
    }

    enum DiagnosticToastInfoConstants {
        static let bottomPaddingPortrait: CGFloat = 5
        static let bottomPaddingLandscape: CGFloat = 16
    }

    @ObservedObject var viewModel: CallingViewModel
    let avatarManager: AvatarViewManagerProtocol
    let viewManager: VideoViewManager

    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation

    var safeAreaIgnoreArea: Edge.Set {
        return getSizeClass() != .iphoneLandscapeScreenSize ? [] : [/* .bottom */]
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

                BottomDrawer(isPresented: viewModel.supportFormViewModel.isDisplayed,
                             hideDrawer: viewModel.supportFormViewModel.hideForm) {
                    reportErrorView
                        .accessibilityElement(children: .contain)
                        .accessibilityAddTraits(.isModal)
                }

                BottomDrawer(isPresented: viewModel.leaveCallConfirmationViewModel.isDisplayed,
                             hideDrawer: viewModel.dismissConfirmLeaveDrawerList) {
                    LeaveCallConfirmationView(viewModel: viewModel.leaveCallConfirmationViewModel)
                }

                BottomDrawer(isPresented: viewModel.moreCallOptionsListViewModel.isDisplayed,
                             hideDrawer: viewModel.dismissMoreCallOptionsDrawerList) {
                    MoreCallOptionsListView(viewModel: viewModel.moreCallOptionsListViewModel)
                }

                BottomDrawer(isPresented: viewModel.audioDeviceListViewModel.isDisplayed,
                             hideDrawer: viewModel.dismissAudioDevicesDrawer) {
                    AudioDevicesListView(viewModel: viewModel.audioDeviceListViewModel)
                }
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
                    if viewModel.isParticipantGridDisplayed && !viewModel.isInPip && viewModel.allowLocalCameraPreview {
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

                    bottomToastDiagnosticsView
                        .accessibilityElement(children: .contain)
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
                .accessibilityElement(children: .contain)
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
            VStack(spacing: 0) {
                bannerView
                HStack {
                    if isIpad {
                        Spacer()
                    } else {
                        EmptyView()
                    }
                    infoHeaderView
                        .frame(width: infoHeaderViewWidth, alignment: .leading)
                        .padding(.leading, InfoHeaderViewConstants.horizontalPadding)
                    Spacer()
                }.accessibilityElement(children: .contain)
                HStack {
                    if isIpad {
                        Spacer()
                    } else {
                        EmptyView()
                    }
                    lobbyWaitingHeaderView
                        .frame(width: infoHeaderViewWidth, alignment: .leading)
                        .padding(.leading, InfoHeaderViewConstants.horizontalPadding)
                    Spacer()
                }
                HStack {
                    if isIpad {
                        Spacer()
                    } else {
                        EmptyView()
                    }
                    lobbyActionErrorView
                        .frame(width: infoHeaderViewWidth, alignment: .leading)
                        .padding(.leading, InfoHeaderViewConstants.horizontalPadding)
                    Spacer()
                }
                HStack {
                    if isIpad {
                        Spacer()
                    } else {
                        EmptyView()
                    }
                    topMessageBarDiagnosticsView
                        .frame(width: infoHeaderViewWidth, alignment: .leading)
                        .padding(.leading, InfoHeaderViewConstants.horizontalPadding)
                    Spacer()
                }
            }
            .padding(.top, Constants.topAlertAreaViewTopPaddin)
            .accessibilityElement(children: .contain)
        }
    }

    var infoHeaderView: some View {
        InfoHeaderView(viewModel: viewModel.infoHeaderViewModel,
                       avatarViewManager: avatarManager)
    }

    var lobbyWaitingHeaderView: some View {
        LobbyWaitingHeaderView(viewModel: viewModel.lobbyWaitingHeaderViewModel,
                       avatarViewManager: avatarManager)
    }

    var lobbyActionErrorView: some View {
        LobbyErrorHeaderView(viewModel: viewModel.lobbyActionErrorViewModel,
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

    var bottomToastDiagnosticsView: some View {
        VStack {
            Spacer()
            BottomToastView(viewModel: viewModel.bottomToastViewModel)
                .padding(
                    EdgeInsets(top: 0,
                               leading: 0,
                               bottom:
                                 getSizeClass() == .iphoneLandscapeScreenSize
                                    ? DiagnosticToastInfoConstants.bottomPaddingLandscape
                                    : DiagnosticToastInfoConstants.bottomPaddingPortrait,
                               trailing: 0)
                )
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isStaticText)
        }.frame(maxWidth: .infinity, alignment: .center)
    }

    var topMessageBarDiagnosticsView: some View {
        VStack {
            ForEach(viewModel.callDiagnosticsViewModel.messageBarStack) { diagnosticMessageBarViewModel in
                MessageBarDiagnosticView(viewModel: diagnosticMessageBarViewModel)
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isStaticText)
            }
            Spacer()
        }
    }
    var reportErrorView: some View {
        return Group {
            SupportFormView(viewModel: viewModel.supportFormViewModel)
        }
    }

}
// swiftlint:enable type_body_length

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
        guard !viewModel.infoHeaderViewModel.isParticipantsListDisplayed else {
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

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

// swiftlint:disable type_body_length
// swiftlint:disable file_length
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
        static let topAlertAreaViewTopPadding: CGFloat = 10.0
    }

    enum DiagnosticToastInfoConstants {
        static let bottomPaddingPortrait: CGFloat = 5
        static let bottomPaddingLandscape: CGFloat = 16
    }

    enum CaptionsInfoConstants {
        static let maxHeight: CGFloat = 115.0
    }

    @ObservedObject var viewModel: CallingViewModel
    @StateObject private var keyboard = KeyboardResponder()
    let avatarManager: AvatarViewManagerProtocol
    let viewManager: VideoViewManager

    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @State private var isAutoCommitted = false

    var safeAreaIgnoreArea: Edge.Set {
        return getSizeClass() != .iphoneLandscapeScreenSize ? [] : [/* .bottom */]
    }

    var isIpad: Bool {
        return getSizeClass() == .ipadScreenSize
    }
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    if getSizeClass() != .iphoneLandscapeScreenSize {
                        portraitCallingView
                    }
                }.frame(width: geometry.size.width,
                        height: geometry.size.height)
            }
            .ignoresSafeArea(isIpad ? [] : .keyboard)
            if getSizeClass() == .iphoneLandscapeScreenSize {
                landscapeCallingView
            }
            errorInfoView
            bottomDrawer
        }
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
        .environment(\.screenSizeClass, getSizeClass())
        .environment(\.appPhase, viewModel.appState)
        .edgesIgnoringSafeArea(safeAreaIgnoreArea)
        .onRotate { newOrientation in
            updateChildViewIfNeededWith(newOrientation: newOrientation)
        }.onAppear {
            resetOrientation()
        }
    }

    var bottomDrawer: some View {
        ZStack {
            BottomDrawer(isPresented: viewModel.supportFormViewModel.isDisplayed,
                         hideDrawer: viewModel.supportFormViewModel.hideForm) {
                reportErrorView
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isModal)
            }
            BottomDrawer(isPresented: viewModel.moreCallOptionsListViewModel.isDisplayed,
                         hideDrawer: viewModel.dismissDrawer) {
                MoreCallOptionsListView(viewModel: viewModel.moreCallOptionsListViewModel,
                avatarManager: avatarManager)
            }
            BottomDrawer(isPresented: viewModel.audioDeviceListViewModel.isDisplayed,
                         hideDrawer: viewModel.dismissDrawer) {
                AudioDevicesListView(viewModel: viewModel.audioDeviceListViewModel,
                avatarManager: avatarManager)
            }
            BottomDrawer(isPresented: viewModel.participantActionViewModel.isDisplayed,
                         hideDrawer: viewModel.dismissDrawer) {
                ParticipantMenuView(viewModel: viewModel.participantActionViewModel,
                                    avatarManager: avatarManager)
            }
            BottomDrawer(isPresented: viewModel.participantListViewModel.isDisplayed,
                         hideDrawer: viewModel.dismissDrawer) {
                ParticipantsListView(viewModel: viewModel.participantListViewModel,
                                     avatarManager: avatarManager)
            }
            BottomDrawer(isPresented: viewModel.captionsLanguageListViewModel.isDisplayed,
                         hideDrawer: viewModel.dismissDrawer) {
                CaptionsLanguageListView(viewModel: viewModel.captionsLanguageListViewModel,
                                         avatarManager: avatarManager)
            }
            BottomDrawer(isPresented: viewModel.captionsRttListViewModel.isDisplayed,
                         hideDrawer: viewModel.dismissDrawer,
                         title: viewModel.captionsRttListViewModel.title,
                         startIcon: CompositeIcon.leftArrow,
                         startIconAction: viewModel.captionsRttListViewModel.backButtonAction) {
                CaptionsRttListView(viewModel: viewModel.captionsRttListViewModel,
                                 avatarManager: avatarManager)
            }
            BottomDrawer(isPresented: viewModel.leaveCallConfirmationViewModel.isDisplayed,
                         hideDrawer: viewModel.dismissDrawer) {
                LeaveCallConfirmationView(
                    viewModel: viewModel.leaveCallConfirmationViewModel,
                    avatarManager: avatarManager)
            }
        }
    }

    var captionsAndRttDrawer: some View {
        return ExpandableDrawer(
            isPresented: Binding(
                get: {
                    viewModel.captionsInfoViewModel.isDisplayed
                },
                set: { newValue in
                    if !newValue {
                        viewModel.dismissDrawer()
                    }
                }
            ),
            hideDrawer: viewModel.dismissDrawer,
            title: viewModel.captionsInfoViewModel?.title,
            endIcon: viewModel.captionsInfoViewModel?.endIcon,
            endIconAction: viewModel.captionsInfoViewModel?.endIconAction,
            endIconAccessibilityValue: viewModel.captionsInfoViewModel?.endIconAccessibilityValue,
            showTextBox: viewModel.captionsInfoViewModel?.isRttAvailable ?? false,
            shouldExpand: viewModel.captionsInfoViewModel?.shouldExpand ?? false,
            expandIconAccessibilityValue: viewModel.captionsInfoViewModel?.expandIconAccessibilityValue,
            collapseIconAccessibilityValue: viewModel.captionsInfoViewModel?.collapseIconAccessibilityValue,
            textBoxHint: viewModel.captionsInfoViewModel?.textBoxHint,
            isAutoCommitted: $isAutoCommitted,
            commitAction: { message, isFinal in
                viewModel.captionsInfoViewModel?.commitMessage(message, isFinal ?? false)
            },
            updateHeightAction: { shouldMaximize in
                viewModel.captionsInfoViewModel.updateLayoutHelight(shouldMaximize)
            },
            content: {
                CaptionsRttInfoView(
                    viewModel: viewModel.captionsInfoViewModel!,
                    avatarViewManager: avatarManager
                )
            }
        ).onReceive(viewModel.captionsInfoViewModel.captionsManager.$isAutoCommit) { shouldClear in
            if shouldClear {
                isAutoCommitted = true
            }
        }
    }

    var captionsAndRttInfoViewPlaceholder: some View {
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: DrawerConstants.collapsedHeight, alignment: .bottom)
            .zIndex(1)
    }

    var captionsAndRttIpadView: some View {
        return CaptionsAndRttLandscapeView(
            title: viewModel.captionsInfoViewModel?.title,
            endIcon: viewModel.captionsInfoViewModel?.endIcon,
            endIconAction: viewModel.captionsInfoViewModel?.endIconAction,
            showTextBox: viewModel.captionsInfoViewModel?.isRttAvailable ?? false,
            textBoxHint: viewModel.captionsInfoViewModel?.textBoxHint,
            isAutoCommitted: $isAutoCommitted,
            commitAction: { message, isFinal in
                viewModel.captionsInfoViewModel?.commitMessage(message, isFinal ?? false)
            },
            content: {
                CaptionsRttInfoView(
                    viewModel: viewModel.captionsInfoViewModel!,
                    avatarViewManager: avatarManager
                )
            }
        ).onReceive(viewModel.captionsInfoViewModel.captionsManager.$isAutoCommit) { shouldClear in
            if shouldClear {
                isAutoCommitted = true
            }
        }
    }

    var portraitCallingView: some View {
        VStack(alignment: .center, spacing: 0) {
            if isIpad {
                HStack {
                    containerView
                    ZStack {
                        if !viewModel.isInPip && viewModel.captionsInfoViewModel.isDisplayed {
                            captionsAndRttIpadView
                        }
                        bottomToastDiagnosticsView
                            .accessibilityElement(children: .contain)
                        captionsErrorView.accessibilityElement(children: .contain)
                    }
                }
                if keyboard.keyboardHeight == 0 {
                    ControlBarView(viewModel: viewModel.controlBarViewModel)
                }
            } else {
                ZStack {
                    containerView.padding(2)
                    if !viewModel.isInPip {
                        captionsAndRttDrawer
                    }
                    bottomToastDiagnosticsView
                        .accessibilityElement(children: .contain)
                    captionsErrorView.accessibilityElement(children: .contain)
                }
                ControlBarView(viewModel: viewModel.controlBarViewModel)

            }
        }
    }

    var landscapeCallingView: some View {
        ZStack {
            HStack(alignment: .center, spacing: 0) {
                containerView
                if !viewModel.isInPip && viewModel.captionsInfoViewModel.isDisplayed {
                    captionsAndRttIpadView.padding(.leading, 2)
                }
                if keyboard.keyboardHeight == 0 {
                    ControlBarView(viewModel: viewModel.controlBarViewModel)
                }
            }
        }
    }

    var containerView: some View {
        Group {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading) {
                    GeometryReader { geometry in
                        ZStack {
                            videoGridView
                                .accessibilityHidden(!viewModel.isVideoGridViewAccessibilityAvailable)
                            if viewModel.isParticipantGridDisplayed &&
                                viewModel.allowLocalCameraPreview {
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
                                .accessibilityIdentifier(
                                    AccessibilityIdentifier.draggablePipViewAccessibilityID.rawValue)
                            }
                        }.zIndex(2)
                            .ignoresSafeArea(isIpad ? [] : .keyboard)
                    }
                    if (viewModel.captionsInfoViewModel.isRttDisplayed ||
                        viewModel.captionsInfoViewModel.isCaptionsDisplayed) &&
                        !viewModel.isInPip && !isIpad && getSizeClass() != .iphoneLandscapeScreenSize {
                        captionsAndRttInfoViewPlaceholder
                    }
                }
                topAlertAreaView
                    .accessibilityElement(children: .contain)
                    .accessibilitySortPriority(1)
                    .accessibilityHidden(viewModel.lobbyOverlayViewModel.isDisplayed
                                         || viewModel.onHoldOverlayViewModel.isDisplayed
                                         || viewModel.loadingOverlayViewModel.isDisplayed)

            }
            .contentShape(Rectangle())
            .animation(.linear(duration: 0.167), value: true)
            .onTapGesture(perform: {
                viewModel.infoHeaderViewModel.toggleDisplayInfoHeaderIfNeeded()
            })
            .accessibilityElement(children: .contain)
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
            .padding(.top, Constants.topAlertAreaViewTopPadding)
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

    var captionsErrorView: some View {
        VStack {
            Spacer()
            CaptionsErrorView(viewModel: viewModel.captionsErrorViewModel)
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
// swiftlint:enable file_length

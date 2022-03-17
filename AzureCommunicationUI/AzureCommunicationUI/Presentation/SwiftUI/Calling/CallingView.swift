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
                .accessibilityElement(children: .contain)
                .accessibility(addTraits: .isModal)
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
            ZStack(alignment: .bottomTrailing) {
                videoGridView
                topAlertAreaView
                if viewModel.isParticipantGridDisplayed {
                    localVideoPipView
                        .padding(.horizontal, -12)
                        .padding(.vertical, -12)
                }
            }
            .contentShape(Rectangle())
            .animation(.linear(duration: 0.167))
            .onTapGesture(perform: {
                viewModel.infoHeaderViewModel.toggleDisplayInfoHeader()
            })
            .modifier(PopupModalView(isPresented: viewModel.isLobbyOverlayDisplayed) {
                LobbyOverlayView()
            })
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
}

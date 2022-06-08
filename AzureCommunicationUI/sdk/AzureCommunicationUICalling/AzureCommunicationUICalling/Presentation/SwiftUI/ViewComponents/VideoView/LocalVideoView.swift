//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

enum LocalVideoViewType {
    case preview
    case localVideoPip
    case localVideofull

    var cameraSwitchButtonAlignment: Alignment {
        switch self {
        case .localVideoPip:
            return .topTrailing
        case .localVideofull:
            return .bottomTrailing
        case .preview:
            return .trailing
        }
    }

    var avatarSize: MSFAvatarSize {
        switch self {
        case .localVideofull,
             .preview:
            return .xxlarge
        case .localVideoPip:
            return .large
        }
    }

    var showDisplayNameTitleView: Bool {
        switch self {
        case .localVideoPip,
             .preview:
            return false
        case .localVideofull:
            return true
        }
    }

    var hasGradient: Bool {
        switch self {
        case .localVideoPip,
             .localVideofull:
            return false
        case .preview:
            return true
        }
    }

}

struct LocalVideoView: View {
    @ObservedObject var viewModel: LocalVideoViewModel
    let viewManager: VideoViewManager
    let viewType: LocalVideoViewType
    let avatarManager: AvatarViewManager
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    @State private var avatarImage: UIImage?
//    @State private var rendererViewId: UIView?
        @State private var localVideoStreamId: String?

    var body: some View {
        Group {
            GeometryReader { geometry in
                if viewModel.cameraOperationalStatus == .on,
//                   let rendererView = rendererView
                   let streamId = localVideoStreamId,
                   let rendererView = viewManager.getLocalVideoRendererView(streamId) {

                    ZStack(alignment: viewType.cameraSwitchButtonAlignment) {
                        VideoRendererView(rendererView: rendererView)
                            .scaledToFill()
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height)
                        if viewType.hasGradient {
                            GradientView()
                        }
                        cameraSwitchButton
                    }
                } else {
                    VStack(alignment: .center, spacing: 5) {
                        CompositeAvatar(displayName: $viewModel.displayName,
                                        avatarImage: $avatarImage,
                                        isSpeaking: false,
                                        avatarSize: viewType.avatarSize)

                        if viewType.showDisplayNameTitleView {
                            Spacer().frame(height: 10)
                            ParticipantTitleView(displayName: $viewModel.displayName,
                                                 isMuted: $viewModel.isMuted,
                                                 titleFont: Fonts.caption1.font,
                                                 mutedIconSize: 16)
                        } else if screenSizeClass == .iphonePortraitScreenSize {
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
                    .accessibilityElement(children: .combine)
                }
            }
        }.onReceive(viewModel.$localVideoStreamId) {
            viewManager.updateDisplayedLocalVideoStream($0)
            if localVideoStreamId != $0 {
                localVideoStreamId = $0
            }
        }.onReceive(avatarManager.$localOptions) {
            avatarImage = $0?.participantViewData.avatarImage
        }
    }

    var cameraSwitchButton: some View {
        let cameraSwitchButtonPaddingPip: CGFloat = -4
        let cameraSwitchButtonPaddingFull: CGFloat = 4
        return Group {
            switch viewType {
            case .localVideoPip:
                IconButton(viewModel: viewModel.cameraSwitchButtonPipViewModel)
                    .padding(cameraSwitchButtonPaddingPip)
            case .localVideofull:
                IconButton(viewModel: viewModel.cameraSwitchButtonFullViewModel)
                    .padding(cameraSwitchButtonPaddingFull)
            default:
                EmptyView()
            }
        }
    }
}

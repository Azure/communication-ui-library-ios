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
    let avatarManager: AvatarViewManagerProtocol
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    @State private var avatarImage: UIImage?
    @State private var localVideoStreamId: String?

    var body: some View {
        Group {
            GeometryReader { geometry in
                if viewModel.cameraOperationalStatus == .on,
                   let streamId = localVideoStreamId,
                   let rendererView = viewManager.getLocalVideoRendererView(streamId) {
                    testView
                    ZStack(alignment: viewType.cameraSwitchButtonAlignment) {
                        VideoRendererView(rendererView: rendererView)
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
                                        avatarImage: Binding.constant(avatarManager
                                            .localParticipantViewData?
                                            .avatarImage),
                                        isSpeaking: false,
                                        avatarSize: viewType.avatarSize)

                        if viewType.showDisplayNameTitleView {
                            Spacer().frame(height: 10)
                            ParticipantTitleView(displayName: $viewModel.displayName,
                                                 isMuted: $viewModel.isMuted,
                                                 isHold: .constant(false),
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
            print("!!!! onReceive $localVideoStreamId")
            viewManager.updateDisplayedLocalVideoStream($0)
            if localVideoStreamId != $0 {
                localVideoStreamId = $0
            }
        }.onReceive(viewModel.$flipAnimation) { _ in
            print()
            guard let streamId = localVideoStreamId,
                  let view = viewManager.getLocalVideoRendererView(streamId) else {
                viewModel.toggleCameraSwitchTapped()
                return
            }
            print("!!!!!! \(view)")
            let blurView = UIVisualEffectView(frame: view.bounds)
            blurView.effect = UIBlurEffect(style: .dark)
            view.addSubview(blurView)
            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                blurView.topAnchor.constraint(equalTo: view.topAnchor),
                blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            UIView.transition(with: view,
                              duration: 2.0,
                              options: .transitionFlipFromLeft,
                              animations: {
                viewModel.toggleCameraSwitchTapped()
            }, completion: { _ in
                blurView.removeFromSuperview()
            })
        }
    }

    var testView: some View {
        if #available(iOS 15.0, *) {
            print("!!!! start update")
            print(Self._printChanges())
            print("!!!! end update")
        }
        return EmptyView()
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

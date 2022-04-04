//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct ParticipantGridCellView: View {
    @ObservedObject var viewModel: ParticipantGridCellViewModel
    let getRemoteParticipantRendererView: (RemoteParticipantVideoViewId) -> ParticipantRendererViewInfo?
    let rendererViewManager: RendererViewManager?
    @State var displayedVideoStreamId: String?
    @State var isVideoChanging: Bool = false
    let avatarSize: CGFloat = 56

    var body: some View {
        Group {
            GeometryReader { geometry in
                if isVideoChanging {
                    EmptyView()
                } else if let rendererViewInfo = getRendererViewInfo() {
                    let zoomable = viewModel.videoViewModel?.videoStreamType == .screenSharing
                    ParticipantGridCellVideoView(videoRendererViewInfo: rendererViewInfo,
                                                 rendererViewManager: rendererViewManager,
                                                 zoomable: zoomable,
                                                 isSpeaking: $viewModel.isSpeaking,
                                                 displayName: $viewModel.displayName,
                                                 isMuted: $viewModel.isMuted)
                } else {
                    avatarView
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibility(label: Text(viewModel.accessibilityLabel))
        }
        .onReceive(viewModel.$videoViewModel) { model in
            let cachedVideoStreamId = displayedVideoStreamId
            if model?.videoStreamId != displayedVideoStreamId {
                displayedVideoStreamId = model?.videoStreamId
            }

            if model?.videoStreamId != cachedVideoStreamId,
               model?.videoStreamId != nil {
                // workaround to force rendererView being recreated
                isVideoChanging = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isVideoChanging = false
                }
            }
        }
    }

    func getRendererViewInfo() -> ParticipantRendererViewInfo? {
        guard let remoteParticipantVideoViewId = getRemoteParticipantVideoViewId() else {
            return nil
        }

        return getRemoteParticipantRendererView(remoteParticipantVideoViewId)
    }

    private func getRemoteParticipantVideoViewId() -> RemoteParticipantVideoViewId? {
        guard let videoStreamId = viewModel.videoViewModel?.videoStreamId,
              !videoStreamId.isEmpty else {
            return nil
        }
        let userId = viewModel.participantIdentifier
        return RemoteParticipantVideoViewId(userIdentifier: userId,
                                            videoStreamIdentifier: videoStreamId)
    }

    var avatarView: some View {
        VStack(alignment: .center, spacing: 5) {
            CompositeAvatar(displayName: $viewModel.displayName,
                            isSpeaking: viewModel.isSpeaking && !viewModel.isMuted)
                .frame(width: avatarSize, height: avatarSize)
            Spacer().frame(height: 10)
            ParticipantTitleView(displayName: $viewModel.displayName,
                                 isMuted: $viewModel.isMuted,
                                 titleFont: Fonts.button1.font,
                                 mutedIconSize: 16)
        }
    }

}

struct ParticipantTitleView: View {
    @Binding var displayName: String?
    @Binding var isMuted: Bool
    let titleFont: Font
    let mutedIconSize: CGFloat
    private let hSpace: CGFloat = 4
    private var isEmpty: Bool {
        return !isMuted && displayName?.trimmingCharacters(in: .whitespaces).isEmpty == true
    }

    var body: some View {
        HStack(alignment: .center, spacing: hSpace, content: {
            if let displayName = displayName,
               !displayName.trimmingCharacters(in: .whitespaces).isEmpty {
                Text(displayName)
                    .font(titleFont)
                    .lineLimit(1)
                    .foregroundColor(Color(StyleProvider.color.onBackground))
            }
            if isMuted {
                Icon(name: .micOff, size: mutedIconSize)
            }
        })
        .padding(.horizontal, isEmpty ? 0 : 4)
        .animation(.default)
    }
}

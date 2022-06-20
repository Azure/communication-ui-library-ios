//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct ParticipantGridCellView: View {
    @ObservedObject var viewModel: ParticipantGridCellViewModel
    let rendererViewManager: RendererViewManager?
    let avatarViewManager: AvatarViewManager
    @State var avatarImage: UIImage?
    @State var displayedVideoStreamId: String?
    @State var isVideoChanging: Bool = false
    let avatarSize: CGFloat = 56

    var body: some View {
        Group {
            GeometryReader { geometry in
                if let videoStreamId = displayedVideoStreamId,
                   let rendererViewInfo = getRendererViewInfo(for: videoStreamId) {
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
            .accessibilityLabel(Text(viewModel.accessibilityLabel))
        }
        .onReceive(viewModel.$videoViewModel) { model in
            if model?.videoStreamId != displayedVideoStreamId {
                displayedVideoStreamId = model?.videoStreamId
            }
        }
        .onReceive(viewModel.$participantIdentifier) {
            updateParticipantViewData(for: $0)
        }
        .onReceive(avatarViewManager.$updatedId) {
            guard $0 == viewModel.participantIdentifier else {
                return
            }

            updateParticipantViewData(for: viewModel.participantIdentifier)
        }
    }

    func getRendererViewInfo(for videoStreamId: String) -> ParticipantRendererViewInfo? {
        guard !videoStreamId.isEmpty else {
            return nil
        }
        let remoteParticipantVideoViewId = RemoteParticipantVideoViewId(userIdentifier: viewModel.participantIdentifier,
                                                                        videoStreamIdentifier: videoStreamId)
        return rendererViewManager?.getRemoteParticipantVideoRendererView(remoteParticipantVideoViewId)
    }

    private func updateParticipantViewData(for identifier: String) {
        guard let participantViewData =
                avatarViewManager.avatarStorage.value(forKey: identifier) else {
            avatarImage = nil
            viewModel.updateParticipantNameIfNeeded(with: nil)
            return
        }

        if avatarImage !== participantViewData.avatarImage {
            avatarImage = participantViewData.avatarImage
        }

        viewModel.updateParticipantNameIfNeeded(with: participantViewData.displayName)
    }

    var avatarView: some View {
        return VStack(alignment: .center, spacing: 5) {
            CompositeAvatar(displayName: $viewModel.displayName,
                            avatarImage: $avatarImage,
                            isSpeaking: viewModel.isSpeaking && !viewModel.isMuted)
            .frame(width: avatarSize, height: avatarSize)
            .opacity(viewModel.isHold ? 0.6 : 1)
            Spacer().frame(height: 10)
            ParticipantTitleView(displayName: $viewModel.displayName,
                                 isMuted: $viewModel.isMuted,
                                 isHold: $viewModel.isHold,
                                 titleFont: Fonts.caption1.font,
                                 mutedIconSize: 16)
            .opacity(viewModel.isHold ? 0.6 : 1)
            if viewModel.isHold {
                Text(viewModel.getOnHoldString())
                    .font(Fonts.caption1.font)
                    .lineLimit(1)
                    .foregroundColor(Color(StyleProvider.color.onBackground))
                    .padding(.top, 8)
            }
        }
    }

}

struct ParticipantTitleView: View {
    @Binding var displayName: String?
    @Binding var isMuted: Bool
    @Binding var isHold: Bool
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
            if isMuted && !isHold {
                Icon(name: .micOff, size: mutedIconSize)
                    .accessibility(hidden: true)
            }
        })
        .padding(.horizontal, isEmpty ? 0 : 4)
        .animation(.default)
    }
}

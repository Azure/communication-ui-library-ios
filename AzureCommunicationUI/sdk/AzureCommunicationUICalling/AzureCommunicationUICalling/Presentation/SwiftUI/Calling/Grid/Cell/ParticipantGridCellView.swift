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
    @State var renderDisplayName: String?
    @State var avatarImage: UIImage?
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
                    let name = Binding(projectedValue: renderDisplayName == nil ?
                                       $viewModel.displayName : $renderDisplayName)
                    ParticipantGridCellVideoView(videoRendererViewInfo: rendererViewInfo,
                                                 rendererViewManager: rendererViewManager,
                                                 zoomable: zoomable,
                                                 isSpeaking: $viewModel.isSpeaking,
                                                 displayName: name,
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
        .onReceive(avatarViewManager.$avatarStorage) {
            updatePersonaData(for: viewModel.participantIdentifier,
                              storage: $0)
        }
        .onReceive(viewModel.$participantIdentifier) {
            updatePersonaData(for: $0,
                              storage: avatarViewManager.avatarStorage)
        }
    }

    func getRendererViewInfo() -> ParticipantRendererViewInfo? {
        guard let remoteParticipantVideoViewId = getRemoteParticipantVideoViewId() else {
            return nil
        }

        return rendererViewManager?.getRemoteParticipantVideoRendererView(remoteParticipantVideoViewId)
    }

    private func updatePersonaData(for identifier: String,
                                   storage: MappedSequence<String, ParticipantViewData>) {
        guard let personaData =
                storage.value(forKey: identifier) else {
            avatarImage = nil
            renderDisplayName = nil
            return
        }

        if avatarImage !== personaData.avatarImage {
            avatarImage = personaData.avatarImage
        }

        if renderDisplayName != personaData.renderDisplayName {
            renderDisplayName = personaData.renderDisplayName
        }
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
        let name = Binding(projectedValue: renderDisplayName == nil ? $viewModel.displayName : $renderDisplayName)
        return VStack(alignment: .center, spacing: 5) {
            CompositeAvatar(displayName: name,
                            avatarImage: $avatarImage,
                            isSpeaking: viewModel.isSpeaking && !viewModel.isMuted)
            .frame(width: avatarSize, height: avatarSize)
            Spacer().frame(height: 10)
            ParticipantTitleView(displayName: name,
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
                    .accessibility(hidden: true)
            }
        })
        .padding(.horizontal, isEmpty ? 0 : 4)
        .animation(.default)
    }
}

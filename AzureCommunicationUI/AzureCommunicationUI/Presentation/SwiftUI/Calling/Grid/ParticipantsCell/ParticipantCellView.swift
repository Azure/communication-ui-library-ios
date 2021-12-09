//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct ParticipantCellView: View {
    @ObservedObject var viewModel: ParticipantCellViewModel
    let getRemoteParticipantRendererView: (RemoteParticipantVideoViewId) -> UIView?
    let avatarBottomSpace: CGFloat = 4
    @State var displayedVideoStreamId: String?
    @State var isVideoChanging: Bool = false

    var body: some View {
        Group {
            GeometryReader { geometry in
                if isVideoChanging {
                    EmptyView()
                } else if let rendererView = getRendererView() {
                    ParticipantRendererView(rendererView: rendererView,
                                                       isSpeaking: $viewModel.isSpeaking,
                                                       displayName: $viewModel.displayName)
                } else {
                    avatarView
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                }
            }
        }
        .onReceive(viewModel.$videoStreamId) { videoStreamId in
            let cachedVideoStreamId = displayedVideoStreamId
            if videoStreamId != displayedVideoStreamId {
                displayedVideoStreamId = videoStreamId
            }

            if videoStreamId != cachedVideoStreamId,
               videoStreamId != nil,
               cachedVideoStreamId != nil {
                // workaround to force rendererView being recreated
                isVideoChanging = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isVideoChanging = false
                }
            }
        }
    }

    func getRendererView() -> UIView? {
        guard let videoStreamId = viewModel.videoStreamId,
              !videoStreamId.isEmpty else {
            return nil
        }
        let userId = viewModel.participantIdentifier
        let remoteParticipantVideoViewId = RemoteParticipantVideoViewId(userIdentifier: userId,
                                                                        videoStreamIdentifier: videoStreamId)

        return getRemoteParticipantRendererView(remoteParticipantVideoViewId)
    }

    var avatarView: some View {
        VStack(alignment: .center, spacing: avatarBottomSpace) {
            CompositeAvatar(displayName: $viewModel.displayName,
                            isSpeaking: $viewModel.isSpeaking)
                .fixedSize()
            Text(viewModel.displayName ?? "")
                .font(Fonts.subhead.font)
                .foregroundColor(Color(Style.color.onBackground))
        }
    }

}

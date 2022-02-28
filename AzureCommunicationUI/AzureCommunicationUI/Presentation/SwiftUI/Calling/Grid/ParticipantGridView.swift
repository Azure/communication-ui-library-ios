//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ParticipantGridView: View {
    let viewModel: ParticipantGridViewModel
    let videoViewManager: VideoViewManager
    let screenSize: ScreenSizeClassType
    @State var gridsCount: Int = 0 // might want to add a state variable here listens to ParticipantGridViewModel
    @State var isAppInForeground: Bool = true
    var body: some View {
        return Group {
            ParticipantGridLayoutView(cellViewModels: viewModel.participantsCellViewModelArr,
                                      getRemoteParticipantRendererView: getRemoteParticipantRendererView(videoViewId:),
                                      screenSize: screenSize,
                                      isAppInForeground: $isAppInForeground)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .id(gridsCount)
            .onReceive(viewModel.$gridsCount) {
                gridsCount = $0
            }
            .onReceive(viewModel.$displayedParticipantInfoModelArr) {
                updateVideoViewManager(displayedRemoteInfoModelArr: $0)
            }
            .onReceive(viewModel.$isAppInForeground) {
                isAppInForeground = $0
            }
    }

    func getRemoteParticipantRendererView(videoViewId: RemoteParticipantVideoViewId) -> ParticipantRendererViewInfo? {
        return videoViewManager.getRemoteParticipantVideoRendererView(videoViewId)
    }

    func updateVideoViewManager(displayedRemoteInfoModelArr: [ParticipantInfoModel]) {
        let videoCacheIds: [RemoteParticipantVideoViewId] = displayedRemoteInfoModelArr.compactMap {
            let screenShareVideoStreamIdentifier = $0.screenShareVideoStreamModel?.videoStreamIdentifier
            let cameraVideoStreamIdentifier = $0.cameraVideoStreamModel?.videoStreamIdentifier
            guard let videoStreamIdentifier = screenShareVideoStreamIdentifier ?? cameraVideoStreamIdentifier else {
                return nil
            }
            return RemoteParticipantVideoViewId(userIdentifier: $0.userIdentifier,
                                                videoStreamIdentifier: videoStreamIdentifier)
        }

        videoViewManager.updateDisplayedRemoteVideoStream(videoCacheIds)

    }
}

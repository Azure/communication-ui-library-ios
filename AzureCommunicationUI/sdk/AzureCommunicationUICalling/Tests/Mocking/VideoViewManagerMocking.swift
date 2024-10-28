//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@testable import AzureCommunicationUICalling

class VideoViewManagerMocking: RendererViewManager {
    var didRenderFirstFrame: ((CGSize) -> Void)?

    func getRemoteParticipantVideoRendererView(_ videoViewId: AzureCommunicationUICalling.RemoteParticipantVideoViewId) -> AzureCommunicationUICalling.ParticipantRendererViewInfo? {
        return nil
    }

    func getRemoteParticipantVideoRendererViewSize() -> CGSize? {
        return nil
    }

    func updateDisplayedRemoteVideoStream(_ videoViewIdArray: [AzureCommunicationUICalling.RemoteParticipantVideoViewId]) {
    }

}

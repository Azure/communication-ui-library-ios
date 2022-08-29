//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

struct RemoteParticipantVideoViewId {
    let userIdentifier: String
    let videoStreamIdentifier: String
}

struct ParticipantRendererViewInfo {
    let rendererView: UIView
    let streamSize: CGSize
}

protocol RendererViewManager: AnyObject {
    var didRenderFirstFrame: ((CGSize) -> Void)? { get set }

    func getRemoteParticipantVideoRendererView
    (_ videoViewId: RemoteParticipantVideoViewId) -> ParticipantRendererViewInfo?
    func getRemoteParticipantVideoRendererViewSize() -> CGSize?
}

class VideoViewManager: NSObject, RendererViewManager {

    private let logger: Logger
    private let callingSDKWrapper: CallingSDKWrapperProtocol

    init(callingSDKWrapper: CallingSDKWrapperProtocol,
         logger: Logger) {
        self.callingSDKWrapper = callingSDKWrapper
        self.logger = logger
    }

    func updateDisplayedRemoteVideoStream(_ videoViewIdArray: [RemoteParticipantVideoViewId]) {
        callingSDKWrapper.updateDisplayedRemoteVideoStream(videoViewIdArray)
    }

    func updateDisplayedLocalVideoStream(_ identifier: String?) {
        callingSDKWrapper.updateDisplayedLocalVideoStream(identifier)
    }

    func getLocalVideoRendererView(_ videoStreamId: String) -> UIView? {
        do {
            let newRendererView = try callingSDKWrapper.getLocalVideoRendererView(videoStreamId)
            return newRendererView
        } catch let error {
            logger.error("Failed to render remote video, reason:\(error.localizedDescription)")
            return nil
        }
    }

    // MARK: ParticipantRendererViewManager
    var didRenderFirstFrame: ((CGSize) -> Void)?

    func getRemoteParticipantVideoRendererView(_ videoViewId: RemoteParticipantVideoViewId)
                                                                -> ParticipantRendererViewInfo? {
        callingSDKWrapper.getRemoteParticipantVideoRendererView(
            videoViewId,
            sizeCallback: didRenderFirstFrame
        )
    }

    func getRemoteParticipantVideoRendererViewSize() -> CGSize? {
        callingSDKWrapper.getRemoteParticipantVideoRendererViewSize()
    }
}

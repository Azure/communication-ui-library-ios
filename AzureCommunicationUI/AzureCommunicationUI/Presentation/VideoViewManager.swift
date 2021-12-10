//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

struct RemoteParticipantVideoViewId {
    let userIdentifier: String
    let videoStreamIdentifier: String
}

class VideoViewManager {
    struct VideoStreamCache {
        var renderer: VideoStreamRenderer
        var rendererView: RendererView
    }
    private let logger: Logger
    private var displayedRemoteParticipantsRendererView = MappedSequence<String, VideoStreamCache>()

    private var localRendererViews = MappedSequence<String, VideoStreamCache>()

    private let callingSDKWrapper: CallingSDKWrapper

    init(callingSDKWrapper: CallingSDKWrapper,
         logger: Logger) {
        self.callingSDKWrapper = callingSDKWrapper
        self.logger = logger
    }

    deinit {
        disposeViews()
    }

    func updateDisplayedRemoteVideoStream(_ videoViewIdArray: [RemoteParticipantVideoViewId]) {
        let displayedKeys = videoViewIdArray.map {
            return generateCacheKey(userIdentifier: $0.userIdentifier, videoStreamId: $0.videoStreamIdentifier)
        }

        displayedRemoteParticipantsRendererView.makeKeyIterator().forEach { [weak self] key in
            if !displayedKeys.contains(key) {
                self?.disposeRemoteParticipantVideoRendererView(key)
            }
        }
    }

    func updateDisplayedLocalVideoStream(_ identifier: String?) {
        localRendererViews.makeKeyIterator().forEach { [weak self] key in
            if identifier != key {
                self?.disposeLocalVideoRendererCache(key)
            }
        }
    }

    func getLocalVideoRendererView(_ videoStreamId: String) -> UIView? {
        if let localRenderCache = localRendererViews.value(forKey: videoStreamId) {
            return localRenderCache.rendererView
        }

        guard let videoStream = callingSDKWrapper.getLocalVideoStream(videoStreamId) else {
            return nil
        }

        do {
            let newRenderer: VideoStreamRenderer = try VideoStreamRenderer(localVideoStream: videoStream)
            let newRendererView: RendererView = try newRenderer.createView(
                withOptions: CreateViewOptions(scalingMode: .crop))

            let cache = VideoStreamCache(renderer: newRenderer,
                                         rendererView: newRendererView)
            localRendererViews.append(forKey: videoStreamId,
                                      value: cache)
            return newRendererView
        } catch let error {
            logger.error("Failed to render remote video, reason:\(error.localizedDescription)")
            return nil
        }

    }

    func getRemoteParticipantVideoRendererView(_ videoViewId: RemoteParticipantVideoViewId) -> UIView? {
        let videoStreamId = videoViewId.videoStreamIdentifier
        let userIdentifier = videoViewId.userIdentifier
        let cacheKey = generateCacheKey(userIdentifier: videoViewId.userIdentifier,
                                        videoStreamId: videoStreamId)
        if let videoStreamCache = displayedRemoteParticipantsRendererView.value(forKey: cacheKey) {
            return videoStreamCache.rendererView
        }

        guard let participant = callingSDKWrapper.getRemoteParticipant(userIdentifier),
              let videoStream = participant.videoStreams.first(where: { stream in
                  return String(stream.id) == videoStreamId
              }) else {
            return nil
        }

        do {
            let options = CreateViewOptions(scalingMode: videoStream.mediaStreamType == .screenSharing ? .fit : .crop)
            let newRenderer: VideoStreamRenderer = try VideoStreamRenderer(remoteVideoStream: videoStream)
            let newRendererView: RendererView = try newRenderer.createView(withOptions: options)

            let cache = VideoStreamCache(renderer: newRenderer,
                                         rendererView: newRendererView)
            displayedRemoteParticipantsRendererView.append(forKey: cacheKey,
                                                           value: cache)

            return newRendererView
        } catch let error {
            logger.error("Failed to render remote video, reason:\(error.localizedDescription)")
            return nil
        }

    }

    private func disposeViews() {
        displayedRemoteParticipantsRendererView.makeKeyIterator().forEach { key in
            self.disposeRemoteParticipantVideoRendererView(key)
        }
        localRendererViews.makeKeyIterator().forEach { key in
            self.disposeLocalVideoRendererCache(key)
        }
    }

    private func disposeRemoteParticipantVideoRendererView(_ cacheId: String) {
        if let renderer = displayedRemoteParticipantsRendererView.removeValue(forKey: cacheId) {
            renderer.renderer.dispose()
        }
    }

    private func disposeLocalVideoRendererCache(_ identifier: String) {
        if let renderer = localRendererViews.removeValue(forKey: identifier) {
            renderer.renderer.dispose()
        }
    }

    private func generateCacheKey(userIdentifier: String, videoStreamId: String) -> String {
        return ("\(userIdentifier):\(videoStreamId)")
    }
}

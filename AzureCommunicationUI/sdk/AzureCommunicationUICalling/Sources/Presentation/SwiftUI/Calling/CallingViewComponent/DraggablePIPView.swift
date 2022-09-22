//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct DraggablePIPView: View {
    let containerBounds: CGRect
    @ObservedObject var viewModel: DraggablePIPViewModel
    let avatarManager: AvatarViewManager
    let viewManager: VideoViewManager
    var pipOptions: PIPViewOptions?

    @State var displayedVideoStreamId: String?
    @State var remoteParticipantAvatar: UIImage?
    @State var pipPosition: CGPoint?
    @GestureState var pipDragStartPosition: CGPoint?
    @Binding var orientation: UIDeviceOrientation
    let screenSize: ScreenSizeClassType

    var body: some View {
        GeometryReader { geometry in
            let size = getPipSize(parentSize: geometry.size)
            pipView
                .background(Color(StyleProvider.color.backgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .allowsHitTesting(pipOptions?.isDraggable ?? true)
                .frame(width: size.width, height: size.height, alignment: .center)
                .position(self.pipPosition ?? getInitialPipPosition(containerBounds: containerBounds))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let containerBounds = getContainerBounds(bounds: geometry.frame(in: .local))
                            let translatedPipPosition = getTranslatedPipPosition(
                                currentPipPosition: self.pipPosition!,
                                pipDragStartPosition: self.pipDragStartPosition,
                                translation: value.translation,
                                isRightToLeft: viewModel.isRightToLeft)
                            self.pipPosition = getBoundedPipPosition(
                                currentPipPosition: self.pipPosition!,
                                requestedPipPosition: translatedPipPosition,
                                bounds: containerBounds)
                        }
                        .updating($pipDragStartPosition) { (_, startLocation, _) in
                            startLocation = startLocation ?? self.pipPosition
                        }
                )
                .onAppear {
                    self.pipPosition = getInitialPipPosition(containerBounds: containerBounds)
                }
                .onChange(of: geometry.size) { _ in
                    self.pipPosition = getInitialPipPosition(containerBounds: geometry.frame(in: .local))
                }
                .onChange(of: orientation) { _ in
                    self.pipPosition = getInitialPipPosition(containerBounds: geometry.frame(in: .local))
                }
        }
        .onReceive(viewModel.$displayedParticipantInfoModel) {
            guard let id = $0?.userIdentifier else {
                return
            }
            updateParticipantViewData(for: id)
        }
        .onReceive(avatarManager.$updatedId) {
            guard let id = viewModel.displayedParticipantInfoModel?.userIdentifier,
                  $0 == id else {
                return
            }

            updateParticipantViewData(for: id)
        }
        .onReceive(viewModel.$videoViewModel) { videoViewModel in
            // the video view size is not updated if used videoViewModel?.videoStreamId directly
            displayedVideoStreamId = videoViewModel?.videoStreamId
        }
    }

    @ViewBuilder
    var pipView: some View {
        if viewModel.displayedParticipantInfoModel != nil {
            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing) {
                    if let videoStreamId = displayedVideoStreamId,
                       let remoteParticipantViewInfo = getRendererViewInfo(for: videoStreamId) {
                        VideoRendererView(rendererView: remoteParticipantViewInfo.rendererView)
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height)
                            .onReceive(viewModel.$displayedParticipantInfoModel) { newModel in
                                let videoViewModel = viewModel.displayedParticipantInfoModel
                                guard newModel?.userIdentifier != videoViewModel?.userIdentifier ||
                                        newModel?.cameraVideoStreamModel?.videoStreamIdentifier !=
                                        videoViewModel?.cameraVideoStreamModel?.videoStreamIdentifier ||
                                        newModel?.screenShareVideoStreamModel?.videoStreamIdentifier !=
                                        videoViewModel?.screenShareVideoStreamModel?.videoStreamIdentifier else {
                                    return
                                }

                                updateDisplayedRemoteVideoStream(with: newModel)
                            }
                    } else {
                        CompositeAvatar(displayName: $viewModel.displayName,
                                        avatarImage: $remoteParticipantAvatar,
                                        isSpeaking: false,
                                        avatarSize: .large)
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                    }

                    if viewModel.localVideoViewModel.cameraOperationalStatus == .on,
                       let streamId = viewModel.localVideoViewModel.localVideoStreamId,
                       viewManager.getLocalVideoRendererView(streamId) != nil {
                        localVideoPipView
                            .frame(width: 24, height: 36)
                    }
                }
            }
        } else {
            localVideoPipView
        }
    }

    var localVideoPipView: some View {
        let shapeCornerRadius: CGFloat = 4
        return Group {
            LocalVideoView(viewModel: viewModel.localVideoViewModel,
                           viewManager: viewManager,
                           viewType: .overlay,
                           avatarManager: avatarManager)
            .background(Color(StyleProvider.color.backgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: shapeCornerRadius))
        }
    }

    private func getInitialPipPosition(containerBounds: CGRect) -> CGPoint {
        //        let margins = pipOptions?.pipDraggableAreaMargins ?? .zero
        switch pipOptions?.defaultPosition ?? .bottomRight {
        case .topRight:
            return CGPoint(
                x: getContainerBounds(bounds: containerBounds).maxX,
                y: getContainerBounds(bounds: containerBounds).minY)
        case .topLeft:
            return CGPoint(
                x: getContainerBounds(bounds: containerBounds).minX,
                y: getContainerBounds(bounds: containerBounds).minY)
        case .bottomRight:
            return CGPoint(
                x: getContainerBounds(bounds: containerBounds).maxX,
                y: getContainerBounds(bounds: containerBounds).maxY)
        case .bottomLeft:
            return CGPoint(
                x: getContainerBounds(bounds: containerBounds).minX,
                y: getContainerBounds(bounds: containerBounds).maxY)
        }

    }

    private func getContainerBounds(bounds: CGRect) -> CGRect {
        let pipSize = getPipSize(parentSize: bounds.size)
        let margins = pipOptions?.pipDraggableAreaMargins
        let defaultMargin: CGFloat = 12.0
        let containerBounds = bounds.inset(by: UIEdgeInsets(
            top: pipSize.height / 2.0 + (margins?.top ?? defaultMargin),
            left: pipSize.width / 2.0 + (margins?.left ?? defaultMargin),
            bottom: pipSize.height / 2.0 + (margins?.bottom ?? defaultMargin),
            right: pipSize.width / 2.0 + (margins?.right ?? defaultMargin)))
        return containerBounds
    }

    private func getTranslatedPipPosition(
        currentPipPosition: CGPoint,
        pipDragStartPosition: CGPoint?,
        translation: CGSize,
        isRightToLeft: Bool) -> CGPoint {
            var translatedPipPosition = pipDragStartPosition ?? currentPipPosition
            translatedPipPosition.x += isRightToLeft
            ? -translation.width
            : translation.width
            translatedPipPosition.y += translation.height
            return translatedPipPosition
        }

    private func getBoundedPipPosition(
        currentPipPosition: CGPoint,
        requestedPipPosition: CGPoint,
        bounds: CGRect) -> CGPoint {
            var boundedPipPosition = currentPipPosition

            if bounds.contains(requestedPipPosition) {
                boundedPipPosition = requestedPipPosition
            } else if requestedPipPosition.x > bounds.minX && requestedPipPosition.x < bounds.maxX {
                boundedPipPosition.x = requestedPipPosition.x
                boundedPipPosition.y = getLimitedValue(
                    value: requestedPipPosition.y,
                    min: bounds.minY,
                    max: bounds.maxY)
            } else if requestedPipPosition.y > bounds.minY && requestedPipPosition.y < bounds.maxY {
                boundedPipPosition.x = getLimitedValue(
                    value: requestedPipPosition.x,
                    min: bounds.minX,
                    max: bounds.maxX)
                boundedPipPosition.y = requestedPipPosition.y
            }

            return boundedPipPosition
        }

    /// Gets the size of the Pip view based on the parent size
    /// - Parameter parentSize: size of the parent view
    /// - Returns: the size of the Pip view based on the parent size
    private func getPipSize(parentSize: CGSize? = nil) -> CGSize {
        return CGSize(width: 80, height: 80)
    }

    private func getLimitedValue(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        var limitedValue = value
        if value < min {
            limitedValue = min
        } else if value > max {
            limitedValue = max
        }
        return limitedValue
    }

    private func getRendererViewInfo(for videoStreamId: String) -> ParticipantRendererViewInfo? {
        guard !videoStreamId.isEmpty,
              let participantId = viewModel.displayedParticipantInfoModel?.userIdentifier else {
            return nil
        }

        let remoteParticipantVideoViewId = RemoteParticipantVideoViewId(userIdentifier: participantId,
                                                                        videoStreamIdentifier: videoStreamId)
        let info = viewManager.getRemoteParticipantVideoRendererView(remoteParticipantVideoViewId)
        return info
    }

    private func updateParticipantViewData(for identifier: String) {
        guard let participantViewData =
                avatarManager.avatarStorage.value(forKey: identifier) else {
            remoteParticipantAvatar = nil
            viewModel.updateParticipantNameIfNeeded(with: nil)
            return
        }

        if remoteParticipantAvatar !== participantViewData.avatarImage {
            remoteParticipantAvatar = participantViewData.avatarImage
        }

        viewModel.updateParticipantNameIfNeeded(with: participantViewData.displayName)
    }

    func updateDisplayedRemoteVideoStream(with model: ParticipantInfoModel?) {
        guard let model = model else {
            viewManager.updateDisplayedRemoteVideoStream([])
            return
        }

        let screenShareVideoStreamIdentifier = model.screenShareVideoStreamModel?.videoStreamIdentifier
        let cameraVideoStreamIdentifier = model.cameraVideoStreamModel?.videoStreamIdentifier
        guard let videoStreamIdentifier = screenShareVideoStreamIdentifier ?? cameraVideoStreamIdentifier else {
            return
        }

        let videoViewId = RemoteParticipantVideoViewId(userIdentifier: model.userIdentifier,
                                            videoStreamIdentifier: videoStreamIdentifier)
        viewManager.updateDisplayedRemoteVideoStream([videoViewId])
    }
}

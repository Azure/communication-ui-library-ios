//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import UIKit

enum CameraDevice {
    case front
    case back
}

public struct CallIdentity {
    public var identifier: String?
}

protocol CallingSDKWrapperProtocol {
    func getRemoteParticipant(_ identifier: String) -> ParticipantInfoModel?
    func getRemoteParticipantVideoRendererView(_ videoViewId: RemoteParticipantVideoViewId,
                                               sizeCallback: ((CGSize) -> Void)?)
                                                                -> ParticipantRendererViewInfo?

    func getRemoteParticipantVideoRendererViewSize() -> CGSize?
    func getLocalVideoStream(_ identifier: String) -> VideoStreamInfoModel?
    func getLocalVideoRendererView(_ identifier: String) throws -> UIView?
    func updateDisplayedLocalVideoStream(_ identifier: String?)
    func updateDisplayedRemoteVideoStream(_ videoViewIdArray: [RemoteParticipantVideoViewId])

    func startPreviewVideoStream() async throws -> String
    func setupCall() async throws
    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws
    func endCall() async throws
    func startCallLocalVideoStream() async throws -> String
    func stopLocalVideoStream() async throws
    func switchCamera() async throws -> CameraDevice
    func muteLocalMic() async throws
    func unmuteLocalMic() async throws
    func holdCall() async throws
    func resumeCall() async throws

    var callingEventsHandler: CallingSDKEventsHandling { get }
}

protocol CallingSDKEventsHandling {
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never> { get }
    var callInfoSubject: PassthroughSubject<CallInfoModel, Never> { get }
    var isRecordingActiveSubject: PassthroughSubject<Bool, Never> { get }
    var isTranscriptionActiveSubject: PassthroughSubject<Bool, Never> { get }
    var isLocalUserMutedSubject: PassthroughSubject<Bool, Never> { get }
}

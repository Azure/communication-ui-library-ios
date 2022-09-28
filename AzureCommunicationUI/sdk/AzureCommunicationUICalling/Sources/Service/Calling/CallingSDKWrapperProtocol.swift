//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import AzureCommunicationCommon
import Combine
import Foundation

enum CameraDevice {
    case front
    case back
}

class RemoteParticipant {
    var identifier: CommunicationIdentifier
    var videoStreams: [RemoteVideoStream]
    var wrappedObject: AnyObject

    init(id: CommunicationIdentifier,
         videoStreams: [RemoteVideoStream],
         wrappedObject: AnyObject) {
        self.identifier = id
        self.videoStreams = videoStreams
        self.wrappedObject = wrappedObject
    }
}

enum MediaStreamType {
    case cameraVideo
    case screenSharing
}

class RemoteVideoStream {
    var id: Int
    var mediaStreamType: MediaStreamType = .cameraVideo
    var wrappedObject: AnyObject

    init(id: Int, mediaStreamType: MediaStreamType, wrappedObject: AnyObject) {
        self.id = id
        self.mediaStreamType = mediaStreamType
        self.wrappedObject = wrappedObject
    }
}

class LocalVideoStream {
    var mediaStreamType: MediaStreamType = .cameraVideo
    var wrappedObject: AnyObject

    init(mediaStreamType: MediaStreamType, wrappedObject: AnyObject) {
        self.mediaStreamType = mediaStreamType
        self.wrappedObject = wrappedObject
    }
}

protocol CallingSDKWrapperProtocol {
    func getRemoteParticipant(_ identifier: String) -> RemoteParticipant?
    func getLocalVideoStream(_ identifier: String) -> LocalVideoStream?

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

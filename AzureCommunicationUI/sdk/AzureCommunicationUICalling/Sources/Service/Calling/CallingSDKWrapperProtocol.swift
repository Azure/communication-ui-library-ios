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

protocol RemoteParticipantIdentifable {
    var identifier: CommunicationIdentifier { get }
}

class RemoteParticipant<WrappedType, VideoStreamType>: RemoteParticipantIdentifable {
    var identifier: CommunicationIdentifier
    var videoStreams: [RemoteVideoStream<VideoStreamType>]
    var wrappedObject: WrappedType

    init(id: CommunicationIdentifier,
         videoStreams: [RemoteVideoStream<VideoStreamType>],
         wrappedObject: WrappedType) {
        self.identifier = id
        self.videoStreams = videoStreams
        self.wrappedObject = wrappedObject
    }
}

enum MediaStreamType {
    case cameraVideo
    case screenSharing
}

class RemoteVideoStream<WrappedType> {
    var id: Int
    var mediaStreamType: MediaStreamType = .cameraVideo
    var wrappedObject: WrappedType

    init(id: Int, mediaStreamType: MediaStreamType, wrappedObject: WrappedType) {
        self.id = id
        self.mediaStreamType = mediaStreamType
        self.wrappedObject = wrappedObject
    }
}

class LocalVideoStream<WrappedType> {
    var mediaStreamType: MediaStreamType = .cameraVideo
    var wrappedObject: WrappedType

    init(mediaStreamType: MediaStreamType, wrappedObject: WrappedType) {
        self.mediaStreamType = mediaStreamType
        self.wrappedObject = wrappedObject
    }
}

protocol CallingSDKWrapperProtocol {
    func getRemoteParticipant<ParticipantType, StreamType>(_ identifier: String)
    -> RemoteParticipant<ParticipantType, StreamType>?
    func getLocalVideoStream<LocalVideoStreamType>(_ identifier: String) -> LocalVideoStream<LocalVideoStreamType>?

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

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

class CompositeRemoteParticipant<WrappedType, VideoStreamType> {
    var identifier: CommunicationIdentifier
    var videoStreams: [CompositeRemoteVideoStream<VideoStreamType>]
    var wrappedObject: WrappedType

    init(id: CommunicationIdentifier,
         videoStreams: [CompositeRemoteVideoStream<VideoStreamType>],
         wrappedObject: WrappedType) {
        self.identifier = id
        self.videoStreams = videoStreams
        self.wrappedObject = wrappedObject
    }
}

enum CompositeMediaStreamType {
    case cameraVideo
    case screenSharing
}

class CompositeRemoteVideoStream<WrappedType> {
    var id: Int
    var mediaStreamType: CompositeMediaStreamType = .cameraVideo
    var wrappedObject: WrappedType

    init(id: Int, mediaStreamType: CompositeMediaStreamType, wrappedObject: WrappedType) {
        self.id = id
        self.mediaStreamType = mediaStreamType
        self.wrappedObject = wrappedObject
    }
}

class CompositeLocalVideoStream<WrappedType> {
    var mediaStreamType: CompositeMediaStreamType = .cameraVideo
    var wrappedObject: WrappedType

    init(mediaStreamType: CompositeMediaStreamType, wrappedObject: WrappedType) {
        self.mediaStreamType = mediaStreamType
        self.wrappedObject = wrappedObject
    }
}

protocol CallingSDKWrapperProtocol {
    func getRemoteParticipant<ParticipantType, StreamType>(_ identifier: String)
    -> CompositeRemoteParticipant<ParticipantType, StreamType>?
    func getLocalVideoStream<LocalVideoStreamType>(_ identifier: String)
    -> CompositeLocalVideoStream<LocalVideoStreamType>?

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
    var callIdSubject: PassthroughSubject<String, Never> { get }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol CallingServiceProtocol {
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never> { get }
    var callInfoSubject: PassthroughSubject<CallInfoModel, Never> { get }
    var isRecordingActiveSubject: PassthroughSubject<Bool, Never> { get }
    var isTranscriptionActiveSubject: PassthroughSubject<Bool, Never> { get }
    var isLocalUserMutedSubject: PassthroughSubject<Bool, Never> { get }
    var callIdSubject: PassthroughSubject<String, Never> { get }
    var dominantSpeakersSubject: CurrentValueSubject<[String], Never> { get }
    var participantRoleSubject: PassthroughSubject<ParticipantRole, Never> { get }

    var networkQualityDiagnosticsSubject: PassthroughSubject<NetworkQualityDiagnosticModel, Never> { get }
    var networkDiagnosticsSubject: PassthroughSubject<NetworkDiagnosticModel, Never> { get }
    var mediaDiagnosticsSubject: PassthroughSubject<MediaDiagnosticModel, Never> { get }

    func setupCall() async throws
    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws
    func endCall() async throws

    func requestCameraPreviewOn() async throws -> String
    func startLocalVideoStream() async throws -> String
    func stopLocalVideoStream() async throws
    func switchCamera() async throws -> CameraDevice

    func muteLocalMic() async throws
    func unmuteLocalMic() async throws

    func holdCall() async throws
    func resumeCall() async throws

    func admitAllLobbyParticipants() async throws
    func admitLobbyParticipant(_ participantId: String) async throws
    func declineLobbyParticipant(_ participantId: String) async throws
}

class CallingService: NSObject, CallingServiceProtocol {

    private let logger: Logger
    private let callingSDKWrapper: CallingSDKWrapperProtocol

    var isRecordingActiveSubject: PassthroughSubject<Bool, Never>
    var isTranscriptionActiveSubject: PassthroughSubject<Bool, Never>

    var isLocalUserMutedSubject: PassthroughSubject<Bool, Never>
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never>
    var callInfoSubject: PassthroughSubject<CallInfoModel, Never>
    var callIdSubject: PassthroughSubject<String, Never>
    var dominantSpeakersSubject: CurrentValueSubject<[String], Never>
    var participantRoleSubject: PassthroughSubject<ParticipantRole, Never>
    var networkQualityDiagnosticsSubject = PassthroughSubject<NetworkQualityDiagnosticModel, Never>()
    var networkDiagnosticsSubject = PassthroughSubject<NetworkDiagnosticModel, Never>()
    var mediaDiagnosticsSubject = PassthroughSubject<MediaDiagnosticModel, Never>()

    init(logger: Logger,
         callingSDKWrapper: CallingSDKWrapperProtocol ) {
        self.logger = logger
        self.callingSDKWrapper = callingSDKWrapper
        isRecordingActiveSubject = callingSDKWrapper.callingEventsHandler.isRecordingActiveSubject
        isTranscriptionActiveSubject = callingSDKWrapper.callingEventsHandler.isTranscriptionActiveSubject
        isLocalUserMutedSubject = callingSDKWrapper.callingEventsHandler.isLocalUserMutedSubject
        participantsInfoListSubject = callingSDKWrapper.callingEventsHandler.participantsInfoListSubject
        callInfoSubject = callingSDKWrapper.callingEventsHandler.callInfoSubject
        callIdSubject = callingSDKWrapper.callingEventsHandler.callIdSubject
        dominantSpeakersSubject = callingSDKWrapper.callingEventsHandler.dominantSpeakersSubject
        participantRoleSubject = callingSDKWrapper.callingEventsHandler.participantRoleSubject
        networkQualityDiagnosticsSubject = callingSDKWrapper.callingEventsHandler.networkQualityDiagnosticsSubject
        networkDiagnosticsSubject = callingSDKWrapper.callingEventsHandler.networkDiagnosticsSubject
        mediaDiagnosticsSubject = callingSDKWrapper.callingEventsHandler.mediaDiagnosticsSubject
    }

    func setupCall() async throws {
        try await callingSDKWrapper.setupCall()
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        try await callingSDKWrapper.startCall(
            isCameraPreferred: isCameraPreferred,
            isAudioPreferred: isAudioPreferred
        )
    }

    func endCall() async throws {
       try await callingSDKWrapper.endCall()
    }

    func requestCameraPreviewOn() async throws -> String {
        return try await callingSDKWrapper.startPreviewVideoStream()
    }

    func startLocalVideoStream() async throws -> String {
        return try await callingSDKWrapper.startCallLocalVideoStream()
    }

    func stopLocalVideoStream() async throws {
        try await callingSDKWrapper.stopLocalVideoStream()
    }

    func switchCamera() async throws -> CameraDevice {
        try await callingSDKWrapper.switchCamera()
    }

    func muteLocalMic() async throws {
        try await callingSDKWrapper.muteLocalMic()
    }

    func unmuteLocalMic() async throws {
        try await callingSDKWrapper.unmuteLocalMic()
    }

    func holdCall() async throws {
        try await callingSDKWrapper.holdCall()
    }

    func resumeCall() async throws {
        try await callingSDKWrapper.resumeCall()
    }

    func admitAllLobbyParticipants() async throws {
        try await callingSDKWrapper.admitAllLobbyParticipants()
    }

    func admitLobbyParticipant(_ participantId: String) async throws {
        try await callingSDKWrapper.admitLobbyParticipant(participantId)
    }

    func declineLobbyParticipant(_ participantId: String) async throws {
        try await callingSDKWrapper.declineLobbyParticipant(participantId)
    }
}

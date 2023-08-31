//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
@testable import AzureCommunicationUICalling

class CallingServiceMocking: CallingServiceProtocol {
    var error: Error?
    var videoStreamId: String?
    var cameraDevice: CameraDevice = .front
    var setupCallCalled: Bool = false
    var startCallCalled: Bool = false
    var endCallCalled: Bool = false
    var holdCallCalled: Bool = false
    var resumeCallCalled: Bool = false

    var localCameraStream: String = "MockCameraStream"

    var startLocalVideoStreamCalled: Bool = false
    var stopLocalVideoStreamCalled: Bool = false
    var switchCameraCalled: Bool = false

    var muteLocalMicCalled: Bool = false
    var unmuteLocalMicCalled: Bool = false

    private func possibleErrorTask() throws -> Task<Void, Error> {
        Task<Void, Error> {
            if let error = self.error {
                throw error
            }
        }
    }

    func startLocalVideoStream() async throws -> String {
        startLocalVideoStreamCalled = true
        let task = Task<String, Error> {
            if let error = self.error {
                throw error
            }
            return videoStreamId ?? ""
        }
        return try await task.value
    }

    func stopLocalVideoStream() async throws {
        stopLocalVideoStreamCalled = true
        try await possibleErrorTask().value
    }

    func switchCamera() async throws -> CameraDevice {
        switchCameraCalled = true
        let task = Task<CameraDevice, Error> {
            if let error = self.error {
                throw error
            }
            return self.cameraDevice
        }
        return try await task.value
    }

    func muteLocalMic() async throws {
        muteLocalMicCalled = true
        try await possibleErrorTask().value
    }

    func unmuteLocalMic() async throws {
        unmuteLocalMicCalled = true
        try await possibleErrorTask().value
    }

    var participantsInfoListSubject = CurrentValueSubject<[ParticipantInfoModel], Never>([])
    var callInfoSubject = PassthroughSubject<CallInfoModel, Never>()
    var isRecordingActiveSubject = PassthroughSubject<Bool, Never>()
    var isTranscriptionActiveSubject = PassthroughSubject<Bool, Never>()
    var callIdSubject = PassthroughSubject<String, Never>()
    var dominantSpeakersSubject = CurrentValueSubject<[String], Never>([])
    var dominantSpeakersModifiedTimestampSubject = PassthroughSubject<Date, Never>()

    var networkQualityDiagnosticsSubject = PassthroughSubject<NetworkQualityDiagnosticModel, Never>()
    var networkDiagnosticsSubject = PassthroughSubject<NetworkDiagnosticModel, Never>()
    var mediaDiagnosticsSubject = PassthroughSubject<MediaDiagnosticModel, Never>()

    var isLocalUserMutedSubject = PassthroughSubject<Bool, Never>()

    func setupCall() async throws {
        setupCallCalled = true
        try await possibleErrorTask().value
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        startCallCalled = true
        try await possibleErrorTask().value
    }

    func endCall() async throws {
        endCallCalled = true
        try await possibleErrorTask().value
    }

    func requestCameraPreviewOn() async throws -> String {
        let task = Task<String, Error> {
            if let error = self.error {
                throw error
            }
            return localCameraStream
        }
        return try await task.value
    }

    func holdCall() async throws {
        holdCallCalled = true
        try await possibleErrorTask().value
    }

    func resumeCall() async throws {
        resumeCallCalled = true
        try await possibleErrorTask().value
    }
}

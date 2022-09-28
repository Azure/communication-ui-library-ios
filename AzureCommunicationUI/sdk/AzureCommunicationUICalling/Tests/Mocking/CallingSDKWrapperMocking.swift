//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

@testable import AzureCommunicationUICalling

class CallingSDKWrapperMocking: CallingSDKWrapperProtocol {
    var error: NSError?
    var callingEventsHandler: CallingSDKEventsHandling = CallingSDKEventsHandler(logger: LoggerMocking())

    func getLocalVideoStream(_ identifier: String) -> LocalVideoStream? {
        return nil
    }

    func startCallLocalVideoStream() async throws -> String {
        return try await Task<String, Error> {
            ""
        }.value
    }

    func stopLocalVideoStream() async throws {
        try await Task<Void, Error> {
        }.value
    }

    func switchCamera() async throws -> CameraDevice {
        switchCameraCallCount += 1
        return try await Task<CameraDevice, Error> {
            .front
        }.value
    }

    var setupCallCallCount: Int = 0
    var startCallCallCount: Int = 0
    var endCallCallCount: Int = 0
    var switchCameraCallCount: Int = 0
    var getRemoteParticipantCallIds: [String] = []

    var holdCallCalled: Bool = false
    var resumeCallCalled: Bool = false
    var muteLocalMicCalled: Bool = false
    var unmuteLocalMicCalled: Bool = false
    var startPreviewVideoStreamCalled: Bool = false

    var isMuted: Bool?
    var isCameraPreferred: Bool?
    var isAudioPreferred: Bool?

    private func possibleErrorTask(onSuccess: @escaping () -> Void) throws -> Task<Void, Error> {
        Task<Void, Error> {
            if let error = self.error {
                throw error
            }
            onSuccess()
        }
    }

    func muteLocalMic() async throws {
        muteLocalMicCalled = true
        return try await possibleErrorTask {
            self.isMuted = true
        }.value
    }

    func unmuteLocalMic() async throws {
        unmuteLocalMicCalled = true
        return try await possibleErrorTask { [self] in
            isMuted = false
        }.value
    }

    func getRemoteParticipant(_ identifier: String) -> RemoteParticipant? {
        getRemoteParticipantCallIds.append(identifier)
        return nil
    }

    func startPreviewVideoStream() async throws -> String {
        startPreviewVideoStreamCalled = true
        return try await Task<String, Error> {
            ""
        }.value
    }

    func setupCall() async throws {
        setupCallCallCount += 1
        try await Task<Void, Error> {}.value
    }

    func setupCallWasCalled() -> Bool {
        return setupCallCallCount > 0
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) async throws {
        startCallCallCount += 1
        self.isCameraPreferred = isCameraPreferred
        self.isAudioPreferred = isAudioPreferred
        try await Task<Void, Error> {}.value
    }

    func holdCall() async throws {
        holdCallCalled = true
        try await possibleErrorTask {}.value
    }

    func resumeCall() async throws {
        resumeCallCalled = true
        try await possibleErrorTask {}.value
    }

    func startCallWasCalled() -> Bool {
        return startCallCallCount > 0
    }

    func endCall() async throws {
        endCallCallCount += 1
        try await Task<Void, Error> {}.value
    }

    func endCallWasCalled() -> Bool {
        return endCallCallCount > 0
    }

    func muteWasCalled() -> Bool {
        return muteLocalMicCalled
    }

    func unmuteWasCalled() -> Bool {
        return unmuteLocalMicCalled
    }

    func videoEnabledWhenJoinCall() -> Bool {
        return isCameraPreferred ?? false
    }

    func mutedWhenJoinCall() -> Bool {
        return !(isAudioPreferred ?? false)
    }

    func switchCameraWasCalled() -> Bool {
        return switchCameraCallCount > 0
    }

}

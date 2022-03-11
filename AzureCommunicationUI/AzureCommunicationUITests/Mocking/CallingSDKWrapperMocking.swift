//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling
@testable import AzureCommunicationUI

class CallingSDKWrapperMocking: CallingSDKWrapper {
    var error: NSError?
    var callingEventsHandler: CallingSDKEventsHandling = CallingSDKEventsHandler(logger: LoggerMocking())

    func getLocalVideoStream(_ identifier: String) -> LocalVideoStream? {
        return nil
    }

    func startCallLocalVideoStream() -> AnyPublisher<String, Error> {
        return AnyPublisher<String, Error>.init(Result<String, Error>.Publisher(("")))
    }

    func stopLocalVideoStream() -> AnyPublisher<Void, Error> {
        return AnyPublisher<Void, Error>.init(Result<Void, Error>.Publisher(()))
    }

    func switchCamera() -> AnyPublisher<CameraDevice, Error> {
        switchCameraCallCount += 1
        return AnyPublisher<CameraDevice, Error>.init(Result<CameraDevice, Error>.Publisher((.front)))
    }

    var setupCallCallCount: Int = 0
    var startCallCallCount: Int = 0
    var endCallCallCount: Int = 0
    var switchCameraCallCount: Int = 0

    var muteLocalMicCalled: Bool = false
    var unmuteLocalMicCalled: Bool = false
    var startPreviewVideoStreamCalled: Bool = false

    var isMuted: Bool?
    var isCameraPreferred: Bool?
    var isAudioPreferred: Bool?

    func muteLocalMic() -> AnyPublisher<Void, Error> {
        muteLocalMicCalled = true
        isMuted = true
        return Future<Void, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func unmuteLocalMic() -> AnyPublisher<Void, Error> {
        unmuteLocalMicCalled = true
        isMuted = false
        return Future<Void, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func getRemoteParticipant(_ identifier: String) -> RemoteParticipant? {
        return nil
    }

    func startPreviewVideoStream() -> AnyPublisher<String, Error> {
        startPreviewVideoStreamCalled = true
        return AnyPublisher<String, Error>.init(Result<String, Error>.Publisher(("")))
    }

    func setupCall() -> AnyPublisher<Void, Error> {
        setupCallCallCount += 1

        return AnyPublisher<Void, Error>.init(Result<Void, Error>.Publisher(()))
    }

    func setupCallWasCalled() -> Bool {
        return setupCallCallCount > 0
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) -> AnyPublisher<Void, Error> {
        startCallCallCount += 1
        self.isCameraPreferred = isCameraPreferred
        self.isAudioPreferred = isAudioPreferred

        return AnyPublisher<Void, Error>.init(Result<Void, Error>.Publisher(()))
    }

    func startCallWasCalled() -> Bool {
        return startCallCallCount > 0
    }

    func endCall() -> AnyPublisher<Void, Error> {
        endCallCallCount += 1

        return AnyPublisher<Void, Error>.init(Result<Void, Error>.Publisher(()))
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

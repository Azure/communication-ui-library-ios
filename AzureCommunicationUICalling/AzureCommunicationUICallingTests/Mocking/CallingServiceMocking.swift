//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
@testable import AzureCommunicationUICalling

class CallingServiceMocking: CallingService {
    var error: Error?
    var videoStreamId: String?
    var cameraDevice: CameraDevice = .front
    var setupCallCalled: Bool = false
    var startCallCalled: Bool = false
    var endCallCalled: Bool = false
    var localCameraStream: String = "MockCameraStream"

    var startLocalVideoStreamCalled: Bool = false
    var stopLocalVideoStreamCalled: Bool = false
    var switchCameraCalled: Bool = false

    var muteLocalMicCalled: Bool = false
    var unmuteLocalMicCalled: Bool = false

    func startLocalVideoStream() -> AnyPublisher<String, Error> {
        startLocalVideoStreamCalled = true
        return Future<String, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success(self.videoStreamId ?? ""))
        }.eraseToAnyPublisher()
    }

    func stopLocalVideoStream() -> AnyPublisher<Void, Error> {
        stopLocalVideoStreamCalled = true
        return Future<Void, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func switchCamera() -> AnyPublisher<CameraDevice, Error> {
        switchCameraCalled = true
        return Future<CameraDevice, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success((self.cameraDevice)))
        }.eraseToAnyPublisher()
    }

    func muteLocalMic() -> AnyPublisher<Void, Error> {
        muteLocalMicCalled = true
        return Future<Void, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func unmuteLocalMic() -> AnyPublisher<Void, Error> {
        unmuteLocalMicCalled = true
        return Future<Void, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success(()))
        }.eraseToAnyPublisher()
    }

    var participantsInfoListSubject = CurrentValueSubject<[ParticipantInfoModel], Never>([])
    var callInfoSubject = PassthroughSubject<CallInfoModel, Never>()
    var isRecordingActiveSubject = PassthroughSubject<Bool, Never>()
    var isTranscriptionActiveSubject = PassthroughSubject<Bool, Never>()

    var isLocalUserMutedSubject = PassthroughSubject<Bool, Never>()

    func setupCall() -> AnyPublisher<Void, Error> {
        setupCallCalled = true

        return Future<Void, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) -> AnyPublisher<Void, Error> {
        startCallCalled = true

        return Future<Void, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func endCall() -> AnyPublisher<Void, Error> {
        endCallCalled = true

        return Future<Void, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success(()))
        }.eraseToAnyPublisher()
    }

    func requestCameraPreviewOn() -> AnyPublisher<String, Error> {
        return Future<String, Error> { promise in
            if let error = self.error {
                return promise(.failure(error))
            }
            return promise(.success((self.localCameraStream)))
        }.eraseToAnyPublisher()
    }
}

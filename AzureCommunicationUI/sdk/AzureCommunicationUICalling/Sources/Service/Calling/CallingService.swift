//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol CallingServiceProtocol {
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never> { get }
    var callInfoSubject: PassthroughSubject<CallInfoModel, Never> { get }
    var isRecordingActiveSubject: PassthroughSubject<Bool, Never> { get }
    var isTranscriptionActiveSubject: PassthroughSubject<Bool, Never> { get }
    var isLocalUserMutedSubject: PassthroughSubject<Bool, Never> { get }

    func setupCall() -> AnyPublisher<Void, Error>
    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) -> AnyPublisher<Void, Error>
    func endCall() -> AnyPublisher<Void, Error>

    func requestCameraPreviewOn() -> AnyPublisher<String, Error>

    func startLocalVideoStream() -> AnyPublisher<String, Error>
    func stopLocalVideoStream() -> AnyPublisher<Void, Error>
    func switchCamera() -> AnyPublisher<CameraDevice, Error>

    func muteLocalMic() -> AnyPublisher<Void, Error>
    func unmuteLocalMic() -> AnyPublisher<Void, Error>

    func holdCall() -> AnyPublisher<Void, Error>
    func resumeCall() -> AnyPublisher<Void, Error>
}

class CallingService: NSObject, CallingServiceProtocol {

    private let logger: Logger
    private let callingSDKWrapper: CallingSDKWrapperProtocol

    var isRecordingActiveSubject: PassthroughSubject<Bool, Never>
    var isTranscriptionActiveSubject: PassthroughSubject<Bool, Never>

    var isLocalUserMutedSubject: PassthroughSubject<Bool, Never>
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never>
    var callInfoSubject: PassthroughSubject<CallInfoModel, Never>

    init(logger: Logger,
         callingSDKWrapper: CallingSDKWrapperProtocol ) {
        self.logger = logger
        self.callingSDKWrapper = callingSDKWrapper
        isRecordingActiveSubject = callingSDKWrapper.callingEventsHandler.isRecordingActiveSubject
        isTranscriptionActiveSubject = callingSDKWrapper.callingEventsHandler.isTranscriptionActiveSubject
        isLocalUserMutedSubject = callingSDKWrapper.callingEventsHandler.isLocalUserMutedSubject
        participantsInfoListSubject = callingSDKWrapper.callingEventsHandler.participantsInfoListSubject
        callInfoSubject = callingSDKWrapper.callingEventsHandler.callInfoSubject
    }

    func setupCall() -> AnyPublisher<Void, Error> {
        asyncToFuture(task: callingSDKWrapper.setupCall)
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) -> AnyPublisher<Void, Error> {
        asyncToFuture { [self] in
            try await callingSDKWrapper.startCall(
                isCameraPreferred: isCameraPreferred,
                isAudioPreferred: isAudioPreferred
            )
        }
    }

    func endCall() -> AnyPublisher<Void, Error> {
        asyncToFuture(task: callingSDKWrapper.endCall)
    }

    func requestCameraPreviewOn() -> AnyPublisher<String, Error> {
        asyncToFuture(task: callingSDKWrapper.startPreviewVideoStream)
    }

    func startLocalVideoStream() -> AnyPublisher<String, Error> {
        asyncToFuture(task: callingSDKWrapper.startCallLocalVideoStream)
    }

    func stopLocalVideoStream() -> AnyPublisher<Void, Error> {
        asyncToFuture(task: callingSDKWrapper.stopLocalVideoStream)
    }

    func switchCamera() -> AnyPublisher<CameraDevice, Error> {
        asyncToFuture(task: callingSDKWrapper.switchCamera)
    }

    func muteLocalMic() -> AnyPublisher<Void, Error> {
        asyncToFuture(task: callingSDKWrapper.muteLocalMic)
    }

    func unmuteLocalMic() -> AnyPublisher<Void, Error> {
        asyncToFuture(task: callingSDKWrapper.unmuteLocalMic)
    }

    func holdCall() -> AnyPublisher<Void, Error> {
        asyncToFuture(task: callingSDKWrapper.holdCall)
    }

    func resumeCall() -> AnyPublisher<Void, Error> {
        asyncToFuture(task: callingSDKWrapper.resumeCall)
    }
}

extension CallingService {
    private func asyncToFuture<Output>(task: @escaping () async throws -> Output) -> AnyPublisher<Output, Error> {
        Future { promise in
            Task {
                do {
                    promise(.success(try await task()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

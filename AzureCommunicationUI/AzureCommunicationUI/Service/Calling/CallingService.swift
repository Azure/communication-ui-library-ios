//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol CallingService {
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
}

class ACSCallingService: NSObject, CallingService {

    private let logger: Logger
    private let callingSDKWrapper: CallingSDKWrapper
    private let cancelBag = CancelBag()

    var isRecordingActiveSubject: PassthroughSubject<Bool, Never>
    var isTranscriptionActiveSubject: PassthroughSubject<Bool, Never>

    var isLocalUserMutedSubject: PassthroughSubject<Bool, Never>
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never>
    var callInfoSubject: PassthroughSubject<CallInfoModel, Never>

    init(logger: Logger,
         callingSDKWrapper: CallingSDKWrapper ) {
        self.logger = logger
        self.callingSDKWrapper = callingSDKWrapper
        isRecordingActiveSubject = callingSDKWrapper.callingEventsHandler.isRecordingActiveSubject
        isTranscriptionActiveSubject = callingSDKWrapper.callingEventsHandler.isTranscriptionActiveSubject
        isLocalUserMutedSubject = callingSDKWrapper.callingEventsHandler.isLocalUserMutedSubject
        participantsInfoListSubject = callingSDKWrapper.callingEventsHandler.participantsInfoListSubject
        callInfoSubject = callingSDKWrapper.callingEventsHandler.callInfoSubject
    }

    func setupCall() -> AnyPublisher<Void, Error> {
        return callingSDKWrapper.setupCall()
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) -> AnyPublisher<Void, Error> {
        return callingSDKWrapper.startCall(
            isCameraPreferred: isCameraPreferred,
            isAudioPreferred: isAudioPreferred
        )
    }

    func endCall() -> AnyPublisher<Void, Error> {
        return callingSDKWrapper.endCall()
    }

    func requestCameraPreviewOn() -> AnyPublisher<String, Error> {
        return callingSDKWrapper.startPreviewVideoStream()
    }

    func startLocalVideoStream() -> AnyPublisher<String, Error> {
        return callingSDKWrapper.startCallLocalVideoStream()
    }

    func stopLocalVideoStream() -> AnyPublisher<Void, Error> {
        return callingSDKWrapper.stopLocalVideoStream()
    }

    func switchCamera() -> AnyPublisher<CameraDevice, Error> {
        return callingSDKWrapper.switchCamera()
    }

    func muteLocalMic() -> AnyPublisher<Void, Error> {
        return callingSDKWrapper.muteLocalMic()
    }

    func unmuteLocalMic() -> AnyPublisher<Void, Error> {
        return callingSDKWrapper.unmuteLocalMic()
    }
}

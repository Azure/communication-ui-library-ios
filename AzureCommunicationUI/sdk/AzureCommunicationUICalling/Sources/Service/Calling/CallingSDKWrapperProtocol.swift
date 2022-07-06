//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling

enum CameraDevice {
    case front
    case back
}

protocol CallingSDKWrapperProtocol {
    func getRemoteParticipant(_ identifier: String) -> RemoteParticipant?
    func startPreviewVideoStream() -> AnyPublisher<String, Error>
    func getLocalVideoStream(_ identifier: String) -> LocalVideoStream?
    func setupCall() -> AnyPublisher<Void, Error>
    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) -> AnyPublisher<Void, Error>
    func endCall() -> AnyPublisher<Void, Error>
    func startCallLocalVideoStream() -> AnyPublisher<String, Error>
    func stopLocalVideoStream() -> AnyPublisher<Void, Error>
    func switchCamera() -> AnyPublisher<CameraDevice, Error>
    func muteLocalMic() -> AnyPublisher<Void, Error>
    func unmuteLocalMic() -> AnyPublisher<Void, Error>
    func holdCall() -> AnyPublisher<Void, Error>
    func resumeCall() -> AnyPublisher<Void, Error>

    var callingEventsHandler: CallingSDKEventsHandling { get }
}

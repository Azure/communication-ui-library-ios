//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

extension Reducer where State == LocalUserState,
                        Actions == LocalUserAction {
    static var liveLocalUserReducer: Self = Reducer { localUserState, action in

        var cameraStatus = localUserState.cameraState.operation
        var cameraDeviceStatus = localUserState.cameraState.device
        var cameraTransmissionStatus = localUserState.cameraState.transmission
        var cameraError = localUserState.cameraState.error

        var audioOperationStatus = localUserState.audioState.operation
        var audioDeviceStatus = localUserState.audioState.device
        var audioError = localUserState.audioState.error

        let displayName = localUserState.displayName
        var localVideoStreamIdentifier = localUserState.localVideoStreamIdentifier

        switch action {
        case .cameraPreviewOnTriggered:
            cameraTransmissionStatus = .local
            cameraStatus = .pending
        case .cameraOnTriggered:
            cameraTransmissionStatus = .remote
            cameraStatus = .pending
        case .cameraOffTriggered:
            cameraStatus = .pending
        case .cameraOnSucceeded(let videoStreamId):
            localVideoStreamIdentifier = videoStreamId
            cameraStatus = .on
        case .cameraOnFailed(let error):
            cameraStatus = .off
            cameraError = error
        case .cameraOffSucceeded:
            localVideoStreamIdentifier = nil
            cameraStatus = .off
        case .cameraOffFailed(let error):
            cameraStatus = .on
            cameraError = error
        case .cameraPausedSucceeded:
            cameraStatus = .paused
        case .cameraPausedFailed(let error):
            cameraError = error
        case .cameraSwitchTriggered:
            cameraDeviceStatus = .switching
        case .cameraSwitchSucceeded(let cameraDevice):
            cameraDeviceStatus = cameraDevice == .front ? .front : .back
        case .cameraSwitchFailed(let previousCamera, let error):
            cameraDeviceStatus = previousCamera
            cameraError = error
        case .microphoneOnTriggered,
                .microphoneOffTriggered:
            audioOperationStatus = .pending
        case .microphonePreviewOn:
            audioOperationStatus = .on
        case .microphoneOnFailed(let error):
            audioOperationStatus = .off
            audioError = error
        case .microphonePreviewOff:
            audioOperationStatus = .off
        case .microphoneMuteStateUpdated(let isMuted):
            audioOperationStatus = isMuted ? .off : .on
        case .microphoneOffFailed(let error):
            audioOperationStatus = .on
            audioError = error
        case .audioDeviceChangeRequested(let device):
            audioDeviceStatus = getRequestedDeviceStatus(for: device)
        case .audioDeviceChangeSucceeded(let device):
            audioDeviceStatus = getSelectedDeviceStatus(for: device)
        case .audioDeviceChangeFailed(let error):
            audioError = error
        }

        let cameraState = LocalUserState.CameraState(operation: cameraStatus,
                                                     device: cameraDeviceStatus,
                                                     transmission: cameraTransmissionStatus,
                                                     error: cameraError)
        let audioState = LocalUserState.AudioState(operation: audioOperationStatus,
                                                   device: audioDeviceStatus,
                                                   error: audioError)
        return LocalUserState(cameraState: cameraState,
                              audioState: audioState,
                              displayName: displayName,
                              localVideoStreamIdentifier: localVideoStreamIdentifier)
    }
}

private func getRequestedDeviceStatus(for audioDeviceType: AudioDeviceType)
-> LocalUserState.AudioDeviceSelectionStatus {
    switch audioDeviceType {
    case .speaker:
        return .speakerRequested
    case .receiver:
        return .receiverRequested
    case .bluetooth:
        return .bluetoothRequested
    case .headphones:
        return .headphonesRequested
    }
}

private func getSelectedDeviceStatus(for audioDeviceType: AudioDeviceType)
-> LocalUserState.AudioDeviceSelectionStatus {
    switch audioDeviceType {
    case .speaker:
        return .speakerSelected
    case .receiver:
        return .receiverSelected
    case .bluetooth:
        return .bluetoothSelected
    case .headphones:
        return .headphonesSelected
    }
}

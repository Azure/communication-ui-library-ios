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
        var microphoneStatus = localUserState.audioState.operation
        var audioDeviceStatus = localUserState.audioState.device
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
            cameraStatus = .error(error)
        case .cameraOffSucceeded:
            localVideoStreamIdentifier = nil
            cameraStatus = .off
        case .cameraOffFailed(let error):
            cameraStatus = .error(error)
        case .cameraPausedSucceeded:
            cameraStatus = .paused
        case .cameraPausedFailed(let error):
            cameraStatus = .error(error)
        case .cameraSwitchTriggered:
            cameraDeviceStatus = .switching
        case .cameraSwitchSucceeded(let cameraDevice):
            cameraDeviceStatus = cameraDevice == .front ? .front : .back
        case .cameraSwitchFailed(let error):
            cameraDeviceStatus = .error(error)
        case .microphoneOnTriggered,
                .microphoneOffTriggered:
            microphoneStatus = .pending
        case .microphonePreviewOn:
            microphoneStatus = .on
        case .microphoneOnFailed(let error):
            microphoneStatus = .error(error)
        case .microphonePreviewOff:
            microphoneStatus = .off
        case .microphoneMuteStateUpdated(let isMuted):
            microphoneStatus = isMuted ? .off : .on
        case .microphoneOffFailed(let error):
            microphoneStatus = .error(error)
        case .audioDeviceChangeRequested(let device):
            audioDeviceStatus = getRequestedDeviceStatus(for: device)
        case .audioDeviceChangeSucceeded(let device):
            audioDeviceStatus = getSelectedDeviceStatus(for: device)
        case .audioDeviceChangeFailed(let error):
            audioDeviceStatus = .error(error)
        }

        let cameraState = LocalUserState.CameraState(operation: cameraStatus,
                                                     device: cameraDeviceStatus,
                                                     transmission: cameraTransmissionStatus)
        let audioState = LocalUserState.AudioState(operation: microphoneStatus,
                                                   device: audioDeviceStatus)
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

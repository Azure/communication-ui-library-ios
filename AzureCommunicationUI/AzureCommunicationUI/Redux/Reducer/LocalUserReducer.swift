//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

struct LocalUserReducer: Reducer {
    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState {
        guard let localUserState = state as? LocalUserState else {
            return state
        }
        var cameraStatus = localUserState.cameraState.operation
        var cameraDeviceStatus = localUserState.cameraState.device
        var cameraTransmissionStatus = localUserState.cameraState.transmission
        var microphoneStatus = localUserState.audioState.operation
        var audioDeviceStatus = localUserState.audioState.device
        let displayName = localUserState.displayName
        var localVideoStreamIdentifier = localUserState.localVideoStreamIdentifier
        switch action {
        case _ as LocalUserAction.CameraPreviewOnTriggered:
            cameraTransmissionStatus = .local
            cameraStatus = .pending
        case _ as LocalUserAction.CameraOnTriggered:
            cameraTransmissionStatus = .remote
            cameraStatus = .pending
        case _ as LocalUserAction.CameraOffTriggered:
            cameraStatus = .pending
        case let action as LocalUserAction.CameraOnSucceeded:
            localVideoStreamIdentifier = action.videoStreamIdentifier
            cameraStatus = .on
        case let action as LocalUserAction.CameraOnFailed:
            cameraStatus = .error(action.error)
        case _ as LocalUserAction.CameraOffSucceeded:
            localVideoStreamIdentifier = nil
            cameraStatus = .off
        case let action as LocalUserAction.CameraOffFailed:
            cameraStatus = .error(action.error)
        case _ as LocalUserAction.CameraPausedSucceeded:
            cameraStatus = .paused
        case let action as LocalUserAction.CameraPausedFailed:
            cameraStatus = .error(action.error)
        case _ as LocalUserAction.CameraSwitchTriggered:
            cameraDeviceStatus = .switching
        case let action as LocalUserAction.CameraSwitchSucceeded:
            cameraDeviceStatus = action.cameraDevice == .front ? .front : .back
        case let action as LocalUserAction.CameraSwitchFailed:
            cameraDeviceStatus = .error(action.error)
        case _ as LocalUserAction.MicrophoneOnTriggered,
             _ as LocalUserAction.MicrophoneOffTriggered:
            microphoneStatus = .pending
        case _ as LocalUserAction.MicrophonePreviewOn:
            microphoneStatus = .on
        case let action as LocalUserAction.MicrophoneOnFailed:
            microphoneStatus = .error(action.error)
        case _ as LocalUserAction.MicrophonePreviewOff:
            microphoneStatus = .off
        case let action as LocalUserAction.MicrophoneMuteStateUpdated:
            microphoneStatus = action.isMuted ? .off : .on
        case let action as LocalUserAction.MicrophoneOffFailed:
            microphoneStatus = .error(action.error)
        case let action as LocalUserAction.AudioDeviceChangeRequested:
            audioDeviceStatus = action.device == .speaker ? .speakerRequested : .receiverRequested
        case let action as LocalUserAction.AudioDeviceChangeSucceeded:
            audioDeviceStatus = action.device == .speaker ? .speakerSelected : .receiverSelected
        case let action as LocalUserAction.AudioDeviceChangeFailed:
            audioDeviceStatus = .error(action.error)
        default:
            return localUserState
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

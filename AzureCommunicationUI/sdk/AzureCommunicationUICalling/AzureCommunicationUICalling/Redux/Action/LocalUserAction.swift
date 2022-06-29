//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

enum LocalUserAction: Equatable {

    case cameraPreviewOnTriggered
    case cameraOnTriggered
    case cameraOnSucceeded(videoStreamIdentifier: String)
    case cameraOnFailed(error: Error)

    case cameraOffTriggered
    case cameraOffSucceeded
    case cameraOffFailed(error: Error)

    case cameraPausedSucceeded
    case cameraPausedFailed(error: Error)

    case cameraSwitchTriggered
    case cameraSwitchSucceeded(cameraDevice: CameraDevice)
    case cameraSwitchFailed(error: Error)

    case microphoneOnTriggered
    case microphoneOnFailed(error: Error)

    case microphoneOffTriggered
    case microphoneOffFailed(error: Error)

    case microphoneMuteStateUpdated(isMuted: Bool)

    case microphonePreviewOn
    case microphonePreviewOff

    case audioDeviceChangeRequested(device: AudioDeviceType)
    case audioDeviceChangeSucceeded(device: AudioDeviceType)
    case audioDeviceChangeFailed(error: Error)

    static func == (lhs: LocalUserAction, rhs: LocalUserAction) -> Bool {

        switch (lhs, rhs) {
        case let (.cameraOnFailed(lErr), .cameraOnFailed(rErr)),
            let (.cameraOffFailed(lErr), .cameraOffFailed(rErr)),
            let (.cameraPausedFailed(lErr), .cameraPausedFailed(rErr)),
            let (.cameraSwitchFailed(lErr), .cameraSwitchFailed(rErr)),
            let (.microphoneOnFailed(lErr), .microphoneOnFailed(rErr)),
            let (.microphoneOffFailed(lErr), .microphoneOffFailed(rErr)),
            let (.audioDeviceChangeFailed(lErr), .audioDeviceChangeFailed(rErr)):

            return (lErr as NSError).code == (rErr as NSError).code

        case (.cameraPreviewOnTriggered, .cameraPreviewOnTriggered),
            (.cameraOnTriggered, .cameraOnTriggered),
            ( .cameraOffTriggered, .cameraOffTriggered),
            ( .cameraOffSucceeded, .cameraOffSucceeded),
            (.cameraPausedSucceeded, .cameraPausedSucceeded),
            (.cameraSwitchTriggered, .cameraSwitchTriggered),
            (.microphoneOnTriggered, .microphoneOnTriggered),
            (.microphoneOffTriggered, .microphoneOffTriggered),
            (.microphonePreviewOn, .microphonePreviewOn),
            (.microphonePreviewOff, .microphonePreviewOff):
            return true

        case let (.audioDeviceChangeRequested(lDev), .audioDeviceChangeRequested(rDev)),
            let (.audioDeviceChangeSucceeded(lDev), .audioDeviceChangeSucceeded(rDev)):
            return lDev == rDev

        case let (.microphoneMuteStateUpdated(lMuted), .microphoneMuteStateUpdated(rMuted)):
            return lMuted == rMuted

        case let (.cameraOnSucceeded(lId), .cameraOnSucceeded(rId)):
            return lId == rId

        case let (.cameraSwitchSucceeded(lDev), .cameraSwitchSucceeded(rDev)):
            return lDev == rDev

        default:
            return false
        }
    }
}

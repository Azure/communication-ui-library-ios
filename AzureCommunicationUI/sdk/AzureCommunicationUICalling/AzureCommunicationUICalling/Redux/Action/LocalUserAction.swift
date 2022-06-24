//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

enum LocalUserAction: Equatable {
    static func == (lhs: LocalUserAction, rhs: LocalUserAction) -> Bool {
        guard type(of: lhs) == type(of: rhs) else {
            return false
        }

        // now handle cases where errors need to be compared
        switch (lhs, rhs) {
        case let (.cameraOnFailed(lErr), .cameraOnFailed(rErr)),
            let (.cameraOffFailed(lErr), .cameraOffFailed(rErr)),
            let (.cameraPausedFailed(lErr), .cameraPausedFailed(rErr)),
            let (.cameraSwitchFailed(lErr), .cameraSwitchFailed(rErr)),
            let (.microphoneOnFailed(lErr), .microphoneOnFailed(rErr)),
            let (.microphoneOffFailed(lErr), .microphoneOffFailed(rErr)),
            let (.audioDeviceChangeFailed(lErr), .audioDeviceChangeFailed(rErr)):

            return (lErr as NSError).code == (rErr as NSError).code

        default:
            return true
        }
    }

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
}

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
        return lhs.typeString == rhs.typeString
    }

    private var typeString: String {
        String(describing: self)
    }
}

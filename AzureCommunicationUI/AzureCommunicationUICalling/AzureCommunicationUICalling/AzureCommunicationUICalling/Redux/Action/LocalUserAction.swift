//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

struct LocalUserAction {
    struct CameraPreviewOnTriggered: Action {}
    struct CameraOnTriggered: Action {}
    struct CameraOnSucceeded: Action {
        var videoStreamIdentifier: String
    }
    struct CameraOnFailed: Action {
        var error: Error
    }

    struct CameraOffTriggered: Action {}
    struct CameraOffSucceeded: Action {}
    struct CameraOffFailed: Action {
        var error: Error
    }

    struct CameraPausedSucceeded: Action {}
    struct CameraPausedFailed: Action {
        var error: Error
    }

    struct CameraSwitchTriggered: Action {}
    struct CameraSwitchSucceeded: Action {
        var cameraDevice: CameraDevice
    }
    struct CameraSwitchFailed: Action {
        var error: Error
    }

    struct MicrophoneOnTriggered: Action {}
    struct MicrophoneOnFailed: Action {
        var error: Error
    }

    struct MicrophoneOffTriggered: Action {}
    struct MicrophoneOffFailed: Action {
        var error: Error
    }

    struct MicrophoneMuteStateUpdated: Action {
        let isMuted: Bool
    }

    struct MicrophonePreviewOn: Action {}
    struct MicrophonePreviewOff: Action {}

    struct AudioDeviceChangeRequested: Action {
        var device: AudioDeviceType
    }
    struct AudioDeviceChangeSucceeded: Action {
        var device: AudioDeviceType
    }
    struct AudioDeviceChangeFailed: Action {
        var error: Error
    }
}

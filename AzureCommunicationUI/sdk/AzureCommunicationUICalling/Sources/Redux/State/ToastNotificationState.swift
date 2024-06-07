//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ToastNotificationKind {
    case networkReceiveQuality
    case networkSendQuality
    case networkReconnectionQuality
    case networkUnavailable
    case networkRelaysUnreachable
    case speakingWhileMicrophoneIsMuted
    case cameraStartFailed
    case cameraStartTimedOut
    case someFeaturesLost
    case someFeaturesGained
}

struct ToastNotificationState {
    let status: ToastNotificationKind?

    init(status: ToastNotificationKind? = nil) {
        self.status = status
    }
}

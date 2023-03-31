//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct DefaultUserState {
    enum CameraState: Equatable {
        case on
        case off
    }

    enum AudioState: Equatable {
        case on
        case off
    }

    let cameraState: CameraState
    let audioState: AudioState

    init(cameraState: CameraState = .off,
         audioState: AudioState = .off) {
        self.cameraState = cameraState
        self.audioState = audioState
    }
}

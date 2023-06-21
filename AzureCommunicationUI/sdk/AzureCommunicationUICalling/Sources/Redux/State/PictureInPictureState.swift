//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum PictureInPictureStatus {
    case none
    case pipModeRequested
    case pipModeEntered
}

struct PictureInPictureState {

    let currentStatus: PictureInPictureStatus

    init(currentStatus: PictureInPictureStatus = .none) {
        self.currentStatus = currentStatus
    }
}

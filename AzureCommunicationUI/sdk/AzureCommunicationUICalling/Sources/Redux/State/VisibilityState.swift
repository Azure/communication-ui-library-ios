//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum VisibilityStatus {
    case visible
    case hideRequested
    case hidden
    case pipModeRequested
    case pipModeEntered
}

struct VisibilityState {

    let currentStatus: VisibilityStatus

    init(currentStatus: VisibilityStatus = .visible) {
        self.currentStatus = currentStatus
    }
}

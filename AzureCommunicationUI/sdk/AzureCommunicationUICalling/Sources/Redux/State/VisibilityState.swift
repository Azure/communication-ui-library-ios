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
    case pipModeLaunching
    case pipModeEntered

    var description: String {
        switch self {
        case .visible:
            return "visible"
        case .hideRequested:
            return "hideRequested"
        case .hidden:
            return "hidden"
        case .pipModeRequested:
            return "pipModeRequested"
        case .pipModeLaunching:
            return "pipModeLaunching"
        case .pipModeEntered:
            return "pipModeEntered"
        }
    }
}

struct VisibilityState {

    let currentStatus: VisibilityStatus

    init(currentStatus: VisibilityStatus = .visible) {
        self.currentStatus = currentStatus
    }
}

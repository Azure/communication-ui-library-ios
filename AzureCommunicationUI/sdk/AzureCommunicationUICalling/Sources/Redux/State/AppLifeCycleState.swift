//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum AppStatus {
    case foreground
    case background
    case willTerminate

    var description: String {
        switch self {
        case .foreground:
            return "foreground"
        case .background:
            return "background"
        case .willTerminate:
            return "willTerminate"
        }
    }
}

struct LifeCycleState {

    let currentStatus: AppStatus

    init(currentStatus: AppStatus = .foreground) {
        self.currentStatus = currentStatus
    }
}

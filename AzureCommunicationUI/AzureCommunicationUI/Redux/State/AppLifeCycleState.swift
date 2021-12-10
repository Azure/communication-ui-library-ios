//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class LifeCycleState: ReduxState {
    enum AppStatus {
        case foreground
        case background
    }

    let currentStatus: AppStatus

    init(currentStatus: AppStatus = .foreground) {
        self.currentStatus = currentStatus
    }

}

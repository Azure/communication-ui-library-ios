//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum NavigationStatus {
    case setup
    case inCall
    case exit
}

struct NavigationState: Equatable {

    let status: NavigationStatus
    let supportFormVisible: Bool
    let endCallConfirmationVisible: Bool

    init(status: NavigationStatus = .setup,
         supportFormVisible: Bool = false,
         endCallConfirmationVisible: Bool = false) {
        self.status = status
        self.supportFormVisible = supportFormVisible
        self.endCallConfirmationVisible = endCallConfirmationVisible
    }

    static func == (lhs: NavigationState, rhs: NavigationState) -> Bool {
        return lhs.status == rhs.status
    }
}

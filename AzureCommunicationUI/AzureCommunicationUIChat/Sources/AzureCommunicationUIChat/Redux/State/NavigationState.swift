//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum NavigationStatus {
    case inChat
    case headless
    case exit
}

struct NavigationState: Equatable {

    let status: NavigationStatus

    init(status: NavigationStatus = .inChat) {
        self.status = status
    }

    static func == (lhs: NavigationState, rhs: NavigationState) -> Bool {
        return lhs.status == rhs.status
    }
}

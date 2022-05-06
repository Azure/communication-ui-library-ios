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

class NavigationState: ReduxState, Equatable {

    let status: NavigationStatus

    public init(status: NavigationStatus = .setup) {
        self.status = status
    }

    static func == (lhs: NavigationState, rhs: NavigationState) -> Bool {
        return lhs.status == rhs.status
    }
}

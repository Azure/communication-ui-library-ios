//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == VisibilityState,
                        Actions == VisibilityAction {
    static var visibilityReducer: Self = Reducer { currentState, action in

        var newStatus = currentState.currentStatus
        switch action {
        case .showNormalEntered:
            newStatus = .visible
        case .hideRequested:
            newStatus = .hideRequested
        case .pipModeRequested:
            newStatus = .pipModeRequested
        case .pipModeLaunching:
            newStatus = .pipModeLaunching
        case .pipModeEntered:
            newStatus = .pipModeEntered
        case .hideEntered:
            newStatus = .hidden
        }
        return VisibilityState(currentStatus: newStatus)
    }
}

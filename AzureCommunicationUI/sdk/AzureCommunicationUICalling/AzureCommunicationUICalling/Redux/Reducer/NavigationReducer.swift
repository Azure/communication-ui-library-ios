//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer where State == NavigationState,
                        Action == Actions {
    static var liveNavigationReducer: Self = Reducer { state, action in
        var navigationStatus = state.status
        switch action {
        case .callingViewLaunched:
            navigationStatus = .inCall
        case .callingAction(.dismissSetup),
                .compositeExitAction:
            navigationStatus = .exit
        case .errorAction(.statusErrorAndCallReset):
            navigationStatus = .setup
        default:
            return state
        }
        return NavigationState(status: navigationStatus)
    }
}

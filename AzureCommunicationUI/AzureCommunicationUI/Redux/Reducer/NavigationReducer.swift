//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

struct NavigationReducer: Reducer {
    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState {
        guard let state = state as? NavigationState else {
            return state
        }
        var navigationStatus = state.status
        switch action {
        case _ as CallingViewLaunched:
            navigationStatus = .inCall
        case _ as CallingAction.DismissSetup,
             _ as CompositeExitAction:
            navigationStatus = .exit
        case _ as ErrorAction.StatusErrorAndCallReset:
            navigationStatus = .setup
        default:
            return state
        }
        return NavigationState(status: navigationStatus)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

struct ErrorReducer: Reducer {
    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState {
        guard let state = state as? ErrorState else {
            return state
        }

        var error = state.error
        var errorCategory = state.errorCategory

        switch action {
        case let action as ErrorAction.FatalErrorUpdated:
            error = action.error
            errorCategory = .fatal
        case let action as ErrorAction.StatusErrorAndCallReset:
            error = action.error
            errorCategory = .callState
        case _ as CallingAction.CallStartRequested:
            print("-----------------empty errorCpde")
            error = nil
            errorCategory = .none
        default:
            return state
        }

        return ErrorState(error: error,
                          errorCategory: errorCategory)
    }
}

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

        var errorType = state.internalError
        var error = state.error
        var errorCategory = state.errorCategory

        switch action {
        case let action as ErrorAction.FatalErrorUpdated:
            errorType = action.internalError
            error = action.error
            errorCategory = .fatal
        case let action as ErrorAction.StatusErrorAndCallReset:
            errorType = action.internalError
            error = action.error
            errorCategory = .callState
        case _ as CallingAction.CallStartRequested:
            errorType = nil
            error = nil
            errorCategory = .none
        default:
            return state
        }

        return ErrorState(internalError: errorType,
                          error: error,
                          errorCategory: errorCategory)
    }
}

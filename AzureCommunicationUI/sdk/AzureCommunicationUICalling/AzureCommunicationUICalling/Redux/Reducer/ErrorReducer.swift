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
        var callingError = state.error
        var errorCategory = state.errorCategory

        switch action {
        case let action as ErrorAction.FatalErrorUpdated:
            errorType = action.internalError
            callingError = action.error
            errorCategory = .fatal
        case let action as ErrorAction.StatusErrorAndCallReset:
            errorType = action.internalError
            callingError = action.error
            errorCategory = .callState
        case _ as CallingAction.CallStartRequested:
            errorType = nil
            callingError = nil
            errorCategory = .none
        default:
            return state
        }

        return ErrorState(internalError: errorType,
                          error: callingError,
                          errorCategory: errorCategory)
    }
}

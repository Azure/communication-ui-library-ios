//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

let liveErrorReducer = Reducer<ErrorState, Actions> { state, action in

    var errorType = state.internalError
    var error = state.error
    var errorCategory = state.errorCategory

    switch action {
    case let .errorAction(.fatalErrorUpdated(internalError, rawError)):
        errorType = internalError
        error = rawError
        errorCategory = .fatal
    case let .errorAction(.statusErrorAndCallReset(internalError, rawError)):
        errorType = internalError
        error = rawError
        errorCategory = .callState
    case .callingAction(.callStartRequested):
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

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == ErrorState,
                        Actions == Action {
    static var liveErrorReducer: Self = Reducer { state, action in

        var errorType = state.internalError
        var error = state.error
        var errorCategory = state.errorCategory

        switch action {
        case let .errorAction(.fatalErrorUpdated(internalError, rawError)):
            errorType = internalError
            error = rawError
            errorCategory = .fatal
        case .chatAction(.initializeChatFailed(let chatError)):
            errorType = .connectFailed
            error = chatError
            errorCategory = .fatal
        case .chatAction(.initializeChatTriggered):
            errorType = nil
            error = nil
            errorCategory = .none

            // Exhaustive unimplemented actions
        case .chatAction(_),
                .participantsAction(_),
                .lifecycleAction(_),
                .repositoryAction(_),
                .compositeExitAction,
                .chatViewLaunched,
                .chatViewHeadless:
            return state
        }

        return ErrorState(internalError: errorType,
                          error: error,
                          errorCategory: errorCategory)
    }
}

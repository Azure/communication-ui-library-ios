//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class ReducerMocking: Reducer {
    var inputAction: Action?
    var inputState: ReduxState?
    var outputState: ReduxState?

    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState {
        self.inputState = state
        self.inputAction = action

        if let outputState = outputState {
            return outputState
        }

        return state

    }
}

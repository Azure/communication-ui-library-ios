//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

extension Reducer {
    static func mockReducer<State, Action>(
        outputState: State? = nil
    ) -> Reducer<State, Action> {

        return Reducer<State, Action> { state, _ in
            if let outputState = outputState {
                return outputState
            }
            return state
        }
    }
}

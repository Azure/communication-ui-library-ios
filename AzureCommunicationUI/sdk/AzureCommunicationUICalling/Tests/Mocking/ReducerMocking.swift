//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation

@testable import AzureCommunicationUICalling

extension Reducer {
    static func mockReducer(
        outputState: State? = nil
    ) -> Reducer<State, Actions> {

        return Reducer<State, Actions> { state, _ in
            if let outputState = outputState {
                return outputState
            }
            return state
        }
    }
}

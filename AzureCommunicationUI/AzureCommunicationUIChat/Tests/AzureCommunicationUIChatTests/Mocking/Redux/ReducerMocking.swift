//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation
@testable import AzureCommunicationUIChat

extension Reducer<AppState, Action> {
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

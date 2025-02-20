//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == RttState, Actions == RttAction {
    static var rttReducer: Self = Reducer { currentState, action in
        var newState = currentState
        switch action {
        case .turnOnRtt:
            newState.isRttOn = true
        case .sendRtt(message: let message, isFinal: let isFinal):
            newState = currentState
        case .updateMaximized(isMaximized: let isMaximized):
            newState.isMaximized = isMaximized
        }
        return newState
    }
}

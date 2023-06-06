//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == PictureInPictureState,
                        Actions == PipAction {
    static var pipReducer: Self = Reducer { currentState, action in

        var currentStatus = currentState.currentStatus
        switch action {
        case .pipModeExited:
            currentStatus = .none
        case .pipModeRequested:
            currentStatus = .pipModeRequested
        case .pipModeEntered:
            currentStatus = .pipModeEntered
        }
        return PictureInPictureState(currentStatus: currentStatus)
    }
}

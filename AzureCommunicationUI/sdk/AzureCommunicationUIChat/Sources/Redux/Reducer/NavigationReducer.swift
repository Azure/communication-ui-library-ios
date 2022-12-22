//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == NavigationState,
                        Actions == Action {
    static var liveNavigationReducer: Self = Reducer { state, action in
        var navigationStatus = state.status
        switch action {
        case .chatViewLaunched:
            navigationStatus = .inChat
        case .chatViewHeadless:
            navigationStatus = .headless
        case .compositeExitAction:
            navigationStatus = .exit
        default:
            return state
        }
        return NavigationState(status: navigationStatus)
    }
}

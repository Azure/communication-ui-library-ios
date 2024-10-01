//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == CallScreenInfoHeaderState,
                        Actions == CallScreenInfoHeaderAction {
    static var callScreenInfoHeaderReducer: Self = Reducer { currentState, action in
        var newState = currentState
        switch action {
        case .updateTitle(let title):
            newState = CallScreenInfoHeaderState(title: title,
                                                 subtitle: currentState.subtitle)
        case .updateSubtitle(let subtitle):
            newState = CallScreenInfoHeaderState(title: currentState.title,
                                                 subtitle: subtitle)
        }
        return newState
    }
}

/* <TIMER_TITLE_FEATURE> */
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == CallScreenInfoHeaderState,
                        Actions == CallScreenInfoHeaderAction {
    static var callScreenInfoHeaderReducer: Self = Reducer { currentState, action in
        var newState = currentState
        switch action {
        case .updateTitle(let title):
            newState.title = title
        case .updateSubtitle(let subtitle):
            newState.subtitle = subtitle
        default:
            return newState
        }
        return newState
    }
}
/* </TIMER_TITLE_FEATURE> */

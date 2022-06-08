//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ErrorCategory {
    case fatal
    case callState
    case none
}

class ErrorState: ReduxState, Equatable {
    let error: CallCompositeInternalError?
    let errorCategory: ErrorCategory
    let error

    init(error: CallCompositeInternalError? = nil,
         errorCategory: ErrorCategory = .none) {
        self.error = error
        self.errorCategory = errorCategory
    }

    static func == (lhs: ErrorState, rhs: ErrorState) -> Bool {
        return (lhs.error?.rawValue == rhs.error?.rawValue)
    }
}

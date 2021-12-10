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
    let error: ErrorEvent?
    let errorCode: String
    let errorCategory: ErrorCategory

    public init(error: ErrorEvent? = nil,
                errorCode: String = "",
                errorCategory: ErrorCategory = .none) {
        self.error = error
        self.errorCode = errorCode
        self.errorCategory = errorCategory
    }

    static func == (lhs: ErrorState, rhs: ErrorState) -> Bool {
        return (lhs.errorCode == rhs.errorCode)
    }
}

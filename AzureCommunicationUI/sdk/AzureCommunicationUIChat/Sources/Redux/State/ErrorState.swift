//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ErrorCategory {
    case fatal
    case chatState
    case none
}

struct ErrorState: Equatable {
    // errorType would be nil for no error status
    let internalError: ChatCompositeInternalError?
    let error: Error?
    let errorCategory: ErrorCategory

    init(internalError: ChatCompositeInternalError? = nil,
         error: Error? = nil,
         errorCategory: ErrorCategory = .none) {
        self.internalError = internalError
        self.error = error
        self.errorCategory = errorCategory
    }

    static func == (lhs: ErrorState, rhs: ErrorState) -> Bool {
        return (lhs.internalError?.rawValue == rhs.internalError?.rawValue)
    }
}

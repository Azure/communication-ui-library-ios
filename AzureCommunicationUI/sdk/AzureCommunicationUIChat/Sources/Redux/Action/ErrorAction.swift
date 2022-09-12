//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ErrorAction: Equatable {
    case fatalErrorUpdated(internalError: ChatCompositeInternalError, error: Error?)
    case statusErrorAndChatReset(internalError: ChatCompositeInternalError, error: Error?)

    static func == (lhs: ErrorAction, rhs: ErrorAction) -> Bool {
        switch (lhs, rhs) {
        case let (.fatalErrorUpdated(internalError: lErr, error: _),
                  .fatalErrorUpdated(internalError: rErr, error: _)):
            return lErr == rErr
        case let (.statusErrorAndChatReset(internalError: lErr, error: _),
                  .statusErrorAndChatReset(internalError: rErr, error: _)):
            return lErr == rErr
        default:
            return false
        }
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

public struct CallCompositeErrorCode {
    public static let callJoin: String = "callJoin"
    public static let callEnd: String = "callEnd"
    public static let tokenExpired: String = "tokenExpired"
}

public struct ErrorEvent {
    public let code: String
    public var error: Error?
}

extension ErrorEvent: Equatable {
    public static func == (lhs: ErrorEvent, rhs: ErrorEvent) -> Bool {
        if let error1 = lhs.error as NSError?,
            let error2 = rhs.error as NSError? {
            return error1.domain == error2.domain
                && error1.code == error2.code
                && "\(error1.description)" == "\(error2.description)"
                && lhs.code == rhs.code
        }

        if let error1 = lhs.error as? CompositeError?,
           let error2 = rhs.error as? CompositeError? {
            return error1 == error2 && lhs.code == rhs.code
        }

        return false
    }
}

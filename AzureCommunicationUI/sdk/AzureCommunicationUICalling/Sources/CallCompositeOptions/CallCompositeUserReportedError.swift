//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// Represents an event where a user reports an issue within the call composite.
public struct CallCompositeUserReportedIssue {

    /// The user's message describing the issue.
    public let userMessage: String
    /// An array of call identifiers associated with the user's session.
    public let debugInfo: DebugInfo

    /// Initializes a new `CallCompositeUserReportedIssueEvent`.
    /// - Parameters:
    ///   - userMessage: A message describing the issue from the user's perspective.
    ///   - debugInfo: Access to the DebugInfo
    public init(userMessage: String,
                debugInfo: DebugInfo) {
        self.userMessage = userMessage
        self.debugInfo = debugInfo
    }
}

extension CallCompositeUserReportedIssue: Equatable {
    public static func == (lhs: CallCompositeUserReportedIssue, rhs: CallCompositeUserReportedIssue) -> Bool {
        return lhs.userMessage == rhs.userMessage
    }
}

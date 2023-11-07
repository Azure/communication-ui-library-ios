//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// Represents an event where a user reports an issue within the call composite.
public struct CallCompositeUserReportedIssue {
    /// The user's message describing the issue.
    public let userMessage: String
    /// An array of URLs pointing to log files for diagnostic purposes.
    public let logFiles: [URL]
    /// An array of call identifiers associated with the user's session.
    public let callIds: [String]

    /// Initializes a new `CallCompositeUserReportedIssueEvent`.
    /// - Parameters:
    ///   - userMessage: A message describing the issue from the user's perspective.
    ///   - logFiles: URLs pointing to logs relevant to the issue.
    ///   - callIds: Identifiers of the calls involved in the issue.
    public init(userMessage: String, logFiles: [URL], callIds: [String]) {
        self.userMessage = userMessage
        self.logFiles = logFiles
        self.callIds = callIds
    }
}

extension CallCompositeUserReportedIssue: Equatable {
    public static func == (lhs: CallCompositeUserReportedIssue, rhs: CallCompositeUserReportedIssue) -> Bool {
        return lhs.userMessage == rhs.userMessage &&
               lhs.logFiles == rhs.logFiles &&
               lhs.callIds == rhs.callIds
    }
}

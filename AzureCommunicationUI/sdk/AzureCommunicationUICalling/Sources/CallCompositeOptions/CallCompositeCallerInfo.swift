//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

/// Call composite caller info.
public struct CallCompositeCallerInfo {
    /// Caller display name.
    public let callerDisplayName: String

    /// Caller CommunicationIdentifier.
    public let callerIdentifier: CommunicationIdentifier

    /// Create an instance of a CallCompositeCallerInfo.
    /// - Parameters:
    ///   - callerDisplayName: Caller display name.
    ///   - callerIdentifier: Caller CommunicationIdentifier.
    public init(callerDisplayName: String,
                callerIdentifier: CommunicationIdentifier) {
        self.callerDisplayName = callerDisplayName
        self.callerIdentifier = callerIdentifier
    }
}

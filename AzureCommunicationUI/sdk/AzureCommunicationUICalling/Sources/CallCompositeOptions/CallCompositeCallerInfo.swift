//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

/// Call composite caller info.
public struct CallCompositeCallerInfo {
    /// Caller display name.
    public let displayName: String

    /// Caller CommunicationIdentifier.
    public let identifier: CommunicationIdentifier

    /// Create an instance of a CallCompositeCallerInfo.
    /// - Parameters:
    ///   - displayName: Caller display name.
    ///   - identifier: Caller CommunicationIdentifier.
    public init(displayName: String,
                identifier: CommunicationIdentifier) {
        self.displayName = displayName
        self.identifier = identifier
    }
}

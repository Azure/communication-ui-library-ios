//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

/// Object for remote options for Call Composite
public struct RemoteOptions {
    /// The unique identifier for the group conversation.
    public let locator: CallComposite.JoinLocator

    /// The token credential used for communication service authentication.
    public let credential: CommunicationTokenCredential

    /// The display name of the local participant when joining the call.
    ///
    /// The limit for string length is 256.
    public let displayName: String?

    /// Create an instance of a RemoteOptions with options.
    /// - Parameters:
    ///   - locator: The JoinLocator type with unique identifier for joining a specific call.
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - displayName: The display name of the local participant for the call. The limit for string length is 256.
    public init(for locator: CallComposite.JoinLocator,
                credential: CommunicationTokenCredential,
                displayName: String? = nil) {
        self.locator = locator
        self.credential = credential
        self.displayName = displayName
    }
}

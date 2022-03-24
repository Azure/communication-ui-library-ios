//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

/// Options for joining a group call.
public struct GroupCallOptions {

    /// The token credential used for communication service authentication.
    public let credential: CommunicationTokenCredential

    /// The unique identifier for the group conversation.
    public let groupId: UUID

    /// The display name of the local participant when joining the call.
    ///
    /// The limit for string length is 256.
    public let displayName: String?

    /// Create an instance of a GroupCallOptions with options.
    /// - Parameters:
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - groupId: The unique identifier for joining a specific group conversation.
    ///   - displayName: The display name of the local participant for the call. The limit for string length is 256.
    public init(communicationTokenCredential: CommunicationTokenCredential,
                groupId: UUID,
                displayName: String) {
        self.credential = communicationTokenCredential
        self.groupId = groupId
        self.displayName = displayName
    }

    /// Create an instance of a GroupCallOptions with options.
    /// - Parameters:
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - groupId: The unique identifier for joining a specific group conversation.
    public init(communicationTokenCredential: CommunicationTokenCredential,
                groupId: UUID) {
        self.credential = communicationTokenCredential
        self.groupId = groupId
        self.displayName = nil
    }
}

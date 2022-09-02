//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

/// ChatComposite Locator for locating chat destination
public enum JoinLocator {
    /// Group Chat with threadId and endpoint
    case groupChat(threadId: String, endpoint: String)
    /// Teams Meeting with string teamsLink URI and endpoint
    case teamsMeeting(teamsLink: String, endpoint: String)
}

/// Object for remote options for Chat Composite
public struct RemoteOptions {
    /// The unique identifier for the group conversation.
    public let locator: JoinLocator

    /// The communication identifier from authentication service.
    public let communicationIdentifier: CommunicationIdentifier

    /// The token credential used for communication service authentication.
    public let credential: CommunicationTokenCredential

    /// The display name of the local participant when joining the chat.
    ///
    /// The limit for string length is 256.
    public let displayName: String?

    /// Create an instance of a RemoteOptions with options.
    /// - Parameters:
    ///   - locator: The JoinLocator type with unique identifier for joining a specific chat.
    ///   - communicationIdentifier: The communication identifier from  authentication service.
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - displayName: The display name of the local participant for the chat. The limit for string length is 256.
    public init(for locator: JoinLocator,
                communicationIdentifier: CommunicationIdentifier,
                credential: CommunicationTokenCredential,
                displayName: String? = nil) {
        self.locator = locator
        self.communicationIdentifier = communicationIdentifier
        self.credential = credential
        self.displayName = displayName
    }
}

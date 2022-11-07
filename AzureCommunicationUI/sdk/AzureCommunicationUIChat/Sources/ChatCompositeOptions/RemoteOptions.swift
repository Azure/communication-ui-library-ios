//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

/// Object for remote options for Chat Composite
public struct RemoteOptions {
    /// The unique thread id for the chat conversation.
    public let threadId: String

    /// The communication identifier from authentication service.
    public let communicationIdentifier: CommunicationIdentifier

    /// The token credential used for communication service authentication.
    public let credential: CommunicationTokenCredential

    /// The endpoint url for the communication service.
    public let endpointUrl: String

    /// The display name of the local participant when joining the chat.
    ///
    /// The limit for string length is 256.
    public let displayName: String?

    /// Create an instance of a RemoteOptions with options.
    /// - Parameters:
    ///   - threadId: The thread id for joining a specific chat conversation.
    ///   - communicationIdentifier: The communication identifier from  authentication service.
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - endpointUrl: The endpoint url for Azure Communication Service.
    ///   - displayName: The display name of the local participant for the chat. The limit for string length is 256.
    public init(threadId: String,
                communicationIdentifier: CommunicationIdentifier,
                credential: CommunicationTokenCredential,
                endpointUrl: String,
                displayName: String? = nil) {
        self.threadId = threadId
        self.communicationIdentifier = communicationIdentifier
        self.credential = credential
        self.endpointUrl = endpointUrl
        self.displayName = displayName
    }
}

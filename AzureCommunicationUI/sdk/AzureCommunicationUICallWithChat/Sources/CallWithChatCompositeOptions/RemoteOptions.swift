//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationUICalling
import AzureCommunicationUIChat

/// CallComposite Locator for locating CallWithChat Composite destination
public enum JoinLocator {
    /// Group Call and Chat with UUID callId, string chatThreadId and Communication Services endpoint
    case groupCallAndChat(callId: UUID, chatThreadId: String, endpoint: String)
    /// Teams Meeting with string teamsLink URI and Communication Services endpoint
    case teamsMeeting(teamsLink: String, endpoint: String)

    func getCallCompositeJoinLocator() -> AzureCommunicationUICalling.JoinLocator {
        switch self {
        case let .groupCallAndChat(groupId, _, _):
            return .groupCall(groupId: groupId)
        case let .teamsMeeting(teamsLink, _):
            return .teamsMeeting(teamsLink: teamsLink)
        }
    }

    func getChatCompositeJoinLocator() -> AzureCommunicationUIChat.JoinLocator {
        switch self {
        case let .groupCallAndChat(_, chatThreadId, endpoint):
            return .groupChat(threadId: chatThreadId, endpoint: endpoint)
        case let .teamsMeeting(teamsLink, endpoint):
            return .teamsMeeting(teamsLink: teamsLink, endpoint: endpoint)
        }
    }
}

/// Object for remote options for CallWithChat Composite
public struct RemoteOptions {
    /// The unique identifier for the group conversation.
    public let locator: JoinLocator

    /// The communication identifier of the current user received from authentication service
    public let communicationIdentifier: CommunicationIdentifier

    /// The token credential used for communication service authentication.
    public let credential: CommunicationTokenCredential

    /// The display name of the local participant when joining the call.
    ///
    /// The limit for string length is 256.
    public let displayName: String?

    /// Create an instance of a RemoteOptions with options.
    /// - Parameters:
    ///   - locator: The JoinLocator type with unique identifier for joining a specific call.
    ///   - communicationIdentifier: The communication identifier received from authentication service.
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - displayName: The display name of the local participant for the call. The limit for string length is 256.
    public init(for locator: JoinLocator,
                communicationIdentifier: CommunicationIdentifier,
                credential: CommunicationTokenCredential,
                displayName: String? = nil) {
        self.locator = locator
        self.credential = credential
        self.displayName = displayName
        self.communicationIdentifier = communicationIdentifier
    }
}

extension RemoteOptions {
    func getChatCompositeRemoteOptions() -> AzureCommunicationUIChat.RemoteOptions {
        return AzureCommunicationUIChat.RemoteOptions(for: locator.getChatCompositeJoinLocator(),
                                                      communicationIdentifier: communicationIdentifier,
                                                      credential: credential,
                                                      displayName: displayName)
    }

    func getCallCompositeRemoteOptions() -> AzureCommunicationUICalling.RemoteOptions {
        return AzureCommunicationUICalling.RemoteOptions(for: locator.getCallCompositeJoinLocator(),
                                                         credential: credential,
                                                         displayName: displayName)
    }
}

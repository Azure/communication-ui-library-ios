//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationCalling

/// CallComposite Locator for locating call destination.
public enum JoinLocator {
    /// Group Call with UUID groupId.
    case groupCall(groupId: UUID)
    /// Teams Meeting with string teamsLink URI.
    case teamsMeeting(teamsLink: String)
    /// Rooms Call with room ID. You need to use LocalOptions parameter for
    /// CallComposite.launch() method with roleHint provided.
    case roomCall(roomId: String)
    case incomingCall(pushNotificationInfo: PushNotificationInfo, acceptIncomingCall: Bool)
    case participantDial(participantMri: String)
}

/// Object for remote options for Call Composite.
public struct RemoteOptions {
    /// The unique identifier for the group conversation.
    public let locator: JoinLocator

    /// The token credential used for communication service authentication.
    public let credential: CommunicationTokenCredential

    /// The display name of the local participant when joining the call.
    ///
    /// The limit for string length is 256.
    public let displayName: String?

    public let enableCallKitInSDK: Bool

    /// Create an instance of a RemoteOptions with options.
    /// - Parameters:
    ///   - locator: The JoinLocator type with unique identifier for joining a specific call.
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - displayName: The display name of the local participant for the call. The limit for string length is 256.
    public init(for locator: JoinLocator,
                credential: CommunicationTokenCredential,
                displayName: String? = nil,
                enableCallKitInSDK: Bool = false
    ) {
        self.locator = locator
        self.credential = credential
        self.displayName = displayName
        self.enableCallKitInSDK = enableCallKitInSDK
    }
}

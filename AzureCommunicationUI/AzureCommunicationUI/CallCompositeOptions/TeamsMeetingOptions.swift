//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

/// Options for joining a Team's meeting.
public struct TeamsMeetingOptions {

    /// The token credential used for communication service authentication.
    public let credential: CommunicationTokenCredential

    /// The URI of the Team's meeting.
    public let meetingLink: String

    /// The display name of the local participant when joining the call.
    ///
    /// The limit for string length is 256.
    public let displayName: String?

    /// Create an instance of a TeamsMeetingOptions with options.
    /// - Parameters:
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - meetingLink: A string representing the full URI of the teams meeting to join.
    ///   - displayName: The display name of the local participant for the call. The limit for string length is 256.
    public init(communicationTokenCredential: CommunicationTokenCredential,
                meetingLink: String,
                displayName: String) {
        self.credential = communicationTokenCredential
        self.meetingLink = meetingLink
        self.displayName = displayName
    }

    /// Create an instance of a TeamsMeetingOptions with options.
    /// - Parameters:
    ///   - credential: The credential used for Azure Communication Service authentication.
    ///   - meetingLink: A string representing the full URI of the teams meeting to join.
    public init(communicationTokenCredential: CommunicationTokenCredential,
                meetingLink: String) {
        self.credential = communicationTokenCredential
        self.meetingLink = meetingLink
        self.displayName = nil
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

public struct TeamsMeetingOptions {
    public let communicationTokenCredential: CommunicationTokenCredential
    public let meetingLink: String
    public let displayName: String?

    public init(communicationTokenCredential: CommunicationTokenCredential,
                meetingLink: String,
                displayName: String) {
        self.communicationTokenCredential = communicationTokenCredential
        self.meetingLink = meetingLink
        self.displayName = displayName
    }

    public init(communicationTokenCredential: CommunicationTokenCredential,
                meetingLink: String) {
        self.communicationTokenCredential = communicationTokenCredential
        self.meetingLink = meetingLink
        self.displayName = nil
    }
}

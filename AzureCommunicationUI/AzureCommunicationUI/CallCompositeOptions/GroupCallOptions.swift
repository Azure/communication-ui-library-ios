//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

public struct GroupCallOptions {
    public let communicationTokenCredential: CommunicationTokenCredential
    public let groupId: UUID
    public let displayName: String?

    public init(communicationTokenCredential: CommunicationTokenCredential,
                groupId: UUID,
                displayName: String) {
        self.communicationTokenCredential = communicationTokenCredential
        self.groupId = groupId
        self.displayName = displayName
    }

    public init(communicationTokenCredential: CommunicationTokenCredential,
                groupId: UUID) {
        self.communicationTokenCredential = communicationTokenCredential
        self.groupId = groupId
        self.displayName = nil
    }
}

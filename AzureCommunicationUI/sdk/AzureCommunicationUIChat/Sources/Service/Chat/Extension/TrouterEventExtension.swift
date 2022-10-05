//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import AzureCore

extension TypingIndicatorReceivedEvent {
    func toUserEventTimestampModel() -> UserEventTimestampModel? {
        return UserEventTimestampModel(
            userIdentifier: self.sender,
            timestamp: self.receivedOn)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import AzureCore
import Foundation

struct UserEventTimestampModel: Equatable {
    let id: String
    let identifier: CommunicationIdentifier
    let timestamp: Iso8601Date

    init?(userIdentifier: CommunicationIdentifier?, timestamp: Iso8601Date?) {
        guard let identifier = userIdentifier,
                let timestamp = timestamp else {
            return nil
        }
        self.id = identifier.stringValue
        self.identifier = identifier
        self.timestamp = timestamp
    }

    static func == (lhs: UserEventTimestampModel, rhs: UserEventTimestampModel) -> Bool {
        return lhs.id == rhs.id
    }
}

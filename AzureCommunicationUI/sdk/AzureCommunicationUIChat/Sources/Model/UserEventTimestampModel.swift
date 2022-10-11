//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCore

struct UserEventTimestampModel: BaseInfoModel, Equatable {
    let id: String
    let identifier: CommunicationIdentifier
    let timestamp: Iso8601Date

    init(userIdentifier: CommunicationIdentifier, timestamp: Iso8601Date) {
        self.id = userIdentifier.stringValue
        self.identifier = userIdentifier
        self.timestamp = timestamp
    }

    static func == (lhs: UserEventTimestampModel, rhs: UserEventTimestampModel) -> Bool {
        return lhs.id == rhs.id
    }
}

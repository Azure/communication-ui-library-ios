//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore
import AzureCommunicationCommon
import AzureCommunicationChat

struct ParticipantInfoModel: Equatable {
    // String id work-around until rawId is implemented
    let id: String
    let identifier: CommunicationIdentifier
    let displayName: String
    let sharedHistoryTime: Iso8601Date?

    init(identifier: CommunicationIdentifier,
         displayName: String,
         sharedHistoryTime: Iso8601Date?) {
        self.id = identifier.stringValue
        self.identifier = identifier
        self.displayName = displayName
        self.sharedHistoryTime = sharedHistoryTime
    }

    static func == (lhs: ParticipantInfoModel, rhs: ParticipantInfoModel) -> Bool {
        return lhs.id == rhs.id
    }
}

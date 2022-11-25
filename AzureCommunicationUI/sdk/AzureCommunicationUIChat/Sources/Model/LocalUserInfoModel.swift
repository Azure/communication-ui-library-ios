//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

struct LocalUserInfoModel {
    let displayName: String?
    let localUserId: String?
    let localUserIdentifier: CommunicationIdentifier?
    let chatThreadId: String?

    init(displayName: String? = nil,
         identifier: CommunicationIdentifier? = nil,
         chatThreadId: String? = nil) {
        self.displayName = displayName
        self.localUserId = identifier?.stringValue
        self.localUserIdentifier = identifier
        self.chatThreadId = chatThreadId
    }
}

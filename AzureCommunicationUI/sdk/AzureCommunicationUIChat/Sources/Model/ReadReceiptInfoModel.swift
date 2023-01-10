//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCore

struct ReadReceiptInfoModel: BaseInfoModel, Equatable {
    let senderIdentifier: CommunicationIdentifier
    let chatMessageId: String
    let readOn: Iso8601Date

    init(senderIdentifier: CommunicationIdentifier, chatMessageId: String, readOn: Iso8601Date) {
        self.senderIdentifier = senderIdentifier
        self.chatMessageId = chatMessageId
        self.readOn = readOn
    }

    static func == (lhs: ReadReceiptInfoModel, rhs: ReadReceiptInfoModel) -> Bool {
        return lhs.chatMessageId == rhs.chatMessageId
    }
}

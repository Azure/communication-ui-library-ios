//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation

struct ChatThreadInfoModel: BaseInfoModel, Equatable {
    let topic: String?
    let receivedOn: Iso8601Date
    let createdBy: String?

    init(topic: String? = nil, receivedOn: Iso8601Date, createdBy: String? = nil) {
        self.topic = topic
        self.receivedOn = receivedOn
        self.createdBy = createdBy
    }
}

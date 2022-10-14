//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation

struct ChatThreadInfoModel: BaseInfoModel {
    let topic: String?
    let receivedOn: Iso8601Date

    init(topic: String? = nil, receivedOn: Iso8601Date) {
        self.topic = topic
        self.receivedOn = receivedOn
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

struct ParticipantsInfoModel: BaseInfoModel {
    let participants: [ParticipantInfoModel]
    let createdOn: Iso8601Date
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ParticipantsAction: Equatable {
    case participantsAdded(participants: [ParticipantInfoModel])
    case participantsRemoved(participants: [ParticipantInfoModel])
}

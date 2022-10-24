//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ParticipantsState {
    let numberOfParticipants: Int
    let threadParticipants: [ParticipantInfoModel]
    init(numberOfParticipants: Int = 0, threadParticipants: [ParticipantInfoModel] = []) {
        self.numberOfParticipants = numberOfParticipants
        self.threadParticipants = threadParticipants
    }
}

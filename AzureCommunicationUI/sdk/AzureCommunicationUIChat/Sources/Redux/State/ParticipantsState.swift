//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ParticipantsState {
    let numberOfParticipants: Int
    let participants: [String: ParticipantInfoModel]
    init(numberOfParticipants: Int = 0, participants: [String: ParticipantInfoModel] = [:]) {
        self.numberOfParticipants = numberOfParticipants
        self.participants = participants
    }
}

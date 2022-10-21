//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ParticipantsState {
    let participantsInfoMap: [String: ParticipantInfoModel]
    let numberOfParticipants: Int = 3

    // MARK: Typing Indicators
    let participantsUpdatedTimestamp: Date
    let typingIndicatorMap: [String: Timer]

    init(participantsInfoMap: [String: ParticipantInfoModel] = [:],
         participantsUpdatedTimestamp: Date = Date(),
         typingIndicatorMap: [String: Timer] = [:]) {
        self.participantsInfoMap = participantsInfoMap
        self.participantsUpdatedTimestamp = participantsUpdatedTimestamp
        self.typingIndicatorMap = typingIndicatorMap
    }
}

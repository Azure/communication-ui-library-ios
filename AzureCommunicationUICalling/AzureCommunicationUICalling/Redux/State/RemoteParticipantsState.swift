//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class RemoteParticipantsState: ReduxState {
    let participantInfoList: [ParticipantInfoModel]
    let lastUpdateTimeStamp: Date

    init(participantInfoList: [ParticipantInfoModel] = [],
         lastUpdateTimeStamp: Date = Date()) {
        self.participantInfoList = participantInfoList
        self.lastUpdateTimeStamp = lastUpdateTimeStamp
    }
}

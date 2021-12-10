//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsListCellViewModel {
    let displayName: String
    let isMuted: Bool

    struct Constants {
        static let localParticipantNamePostfix: String = "(You)"
    }

    init(localUserState: LocalUserState) {
        if let displayName = localUserState.displayName {
            self.displayName = "\(displayName) \(Constants.localParticipantNamePostfix)"
        } else {
            self.displayName = "\(Constants.localParticipantNamePostfix)"
        }

        self.isMuted = localUserState.audioState.operation != .on
    }

    init(participantInfoModel: ParticipantInfoModel) {
        self.displayName = participantInfoModel.displayName
        self.isMuted = participantInfoModel.isMuted
    }
}

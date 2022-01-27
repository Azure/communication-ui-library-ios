//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsListCellViewModel {
    let displayName: String
    let isMuted: Bool

    init(localUserState: LocalUserState) {
        if let displayName = localUserState.displayName,
           !displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            self.displayName = "\(displayName) \(StringConstants.localParticipantNamePostfix)"
        } else {
            self.displayName = "\(StringConstants.defaultEmptyName) \(StringConstants.localParticipantNamePostfix)"
        }

        self.isMuted = localUserState.audioState.operation != .on
    }

    init(participantInfoModel: ParticipantInfoModel) {
        self.displayName = participantInfoModel.displayName
        self.isMuted = participantInfoModel.isMuted
    }
}

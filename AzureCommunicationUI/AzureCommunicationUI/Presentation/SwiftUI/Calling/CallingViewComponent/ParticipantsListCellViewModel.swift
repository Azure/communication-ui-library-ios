//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsListCellViewModel {
    let displayName: String
    let isParticipantNameEmpty: Bool
    let isMuted: Bool

    init(localUserState: LocalUserState) {
        if let displayName = localUserState.displayName,
           !displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            self.displayName = "\(displayName) \(StringConstants.localParticipantNamePostfix)"
            self.isParticipantNameEmpty = false
        } else {
            self.displayName = "\(StringConstants.defaultEmptyName) \(StringConstants.localParticipantNamePostfix)"
            self.isParticipantNameEmpty = true
        }

        self.isMuted = localUserState.audioState.operation != .on
    }

    init(participantInfoModel: ParticipantInfoModel) {
        if participantInfoModel.displayName.trimmingCharacters(in: .whitespaces).isEmpty {
            self.displayName = "\(StringConstants.defaultEmptyName)"
            self.isParticipantNameEmpty = true
        } else {
            self.displayName = participantInfoModel.displayName
            self.isParticipantNameEmpty = false
        }

        self.isMuted = participantInfoModel.isMuted
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsListCellViewModel {
    let displayName: String
    let isMuted: Bool
    let isLocalParticipant: Bool

    init(localUserState: LocalUserState) {
        self.displayName = localUserState.displayName ?? ""
        self.isMuted = localUserState.audioState.operation != .on
        self.isLocalParticipant = true
    }

    init(participantInfoModel: ParticipantInfoModel) {
        self.displayName = participantInfoModel.displayName
        self.isMuted = participantInfoModel.isMuted
        self.isLocalParticipant = false
    }

    func getCellDisplayName(localizationProvider: LocalizationProvider) -> String {
        let isNameEmpty = displayName.trimmingCharacters(in: .whitespaces).isEmpty
        if isLocalParticipant {
            let localDisplayName = isNameEmpty
            ? localizationProvider.getLocalizedString(.unnamedParticipant)
            : displayName
            return localizationProvider.getLocalizedString(.localeParticipantWithSuffix, localDisplayName)
        } else {
            return isNameEmpty
            ? localizationProvider.getLocalizedString(.unnamedParticipant)
            : displayName
        }
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsListCellViewModel {
    let displayName: String
    let isMuted: Bool
    let isLocalParticipant: Bool
    let localizationProvider: LocalizationProvider

    init(localUserState: LocalUserState,
         localizationProvider: LocalizationProvider) {
        self.localizationProvider = localizationProvider
        self.displayName = localUserState.displayName ?? ""
        self.isMuted = localUserState.audioState.operation != .on
        self.isLocalParticipant = true
    }

    init(participantInfoModel: ParticipantInfoModel,
         localizationProvider: LocalizationProvider) {
        self.localizationProvider = localizationProvider
        self.displayName = participantInfoModel.displayName
        self.isMuted = participantInfoModel.isMuted
        self.isLocalParticipant = false
    }

    func getCellDisplayName() -> String {
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

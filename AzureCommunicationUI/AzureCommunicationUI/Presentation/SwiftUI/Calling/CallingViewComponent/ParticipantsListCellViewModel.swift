//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsListCellViewModel {
    let displayName: String
    let isMuted: Bool
    let isLocalParticipant: Bool
    let localizationProvider: LocalizationProviderProtocol

    init(localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
        self.displayName = localUserState.displayName ?? ""
        self.isMuted = localUserState.audioState.operation != .on
        self.isLocalParticipant = true
    }

    init(participantInfoModel: ParticipantInfoModel,
         localizationProvider: LocalizationProviderProtocol) {
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

    func getCellAccessibilityLabel() -> String {
        let displayName = getCellDisplayName()
        return isMuted
        ? displayName + localizationProvider.getLocalizedString(.muted)
        : displayName + localizationProvider.getLocalizedString(.unmuted)
    }
}

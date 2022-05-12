//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsListCellViewModel {
    let participantId: String?
    let isMuted: Bool
    let isLocalParticipant: Bool
    let localizationProvider: LocalizationProviderProtocol
    private let displayName: String

    init(localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol) {
        participantId = nil
        self.localizationProvider = localizationProvider
        self.displayName = localUserState.displayName ?? ""
        self.isMuted = localUserState.audioState.operation != .on
        self.isLocalParticipant = true
    }

    init(participantInfoModel: ParticipantInfoModel,
         localizationProvider: LocalizationProviderProtocol) {
        participantId = participantInfoModel.userIdentifier
        self.localizationProvider = localizationProvider
        self.displayName = participantInfoModel.displayName
        self.isMuted = participantInfoModel.isMuted
        self.isLocalParticipant = false
    }

    func getPersonaData(from avatarViewManager: AvatarViewManager?) -> PersonaData? {
        guard let avatarViewManager = avatarViewManager else {
            return nil
        }

        var personaData: PersonaData?
        if isLocalParticipant {
            personaData = avatarViewManager.localDataOptions?.localPersona
        } else if let participantId = participantId {
            personaData = avatarViewManager.avatarStorage.value(forKey: participantId)
        }
        return personaData
    }

    func getCellDisplayName(with personaData: PersonaData?) -> String {
        let name = getParticipantName(with: personaData)
        let isNameEmpty = name.trimmingCharacters(in: .whitespaces).isEmpty
        let displayName = isNameEmpty
        ? localizationProvider.getLocalizedString(.unnamedParticipant)
        : name
        return isLocalParticipant
        ? localizationProvider.getLocalizedString(.localeParticipantWithSuffix, displayName)
        : displayName
    }

    func getCellAccessibilityLabel(with personaData: PersonaData?) -> String {
        let displayName = getCellDisplayName(with: personaData)
        return isMuted
        ? displayName + localizationProvider.getLocalizedString(.muted)
        : displayName + localizationProvider.getLocalizedString(.unmuted)
    }

    func getParticipantName(with personaData: PersonaData?) -> String {
        let name: String
        if let data = personaData, let renderDisplayName = data.renderDisplayName {
            let isPersonaNameEmpty = renderDisplayName.trimmingCharacters(in: .whitespaces).isEmpty
            name = isPersonaNameEmpty ? displayName : renderDisplayName
        } else {
            name = displayName
        }
        return name
    }
}

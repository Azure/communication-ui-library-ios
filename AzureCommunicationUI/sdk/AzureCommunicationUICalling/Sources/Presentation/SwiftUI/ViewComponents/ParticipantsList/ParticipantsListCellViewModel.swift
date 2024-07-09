//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsListCellViewModel: BaseDrawerItemViewModel {
    let participantId: String?
    let isMuted: Bool
    let isHold: Bool
    let isLocalParticipant: Bool
    let localizationProvider: LocalizationProviderProtocol
    let isInLobby: Bool
    let confirmTitle: String?
    let confirmAccept: String?
    let confirmDeny: String?
    let accept: (() -> Void)?
    let deny: (() -> Void)?
    private let displayName: String

    init(localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol) {
        participantId = nil
        self.localizationProvider = localizationProvider
        self.displayName = localUserState.displayName ?? ""
        self.isMuted = localUserState.audioState.operation != .on
        self.isLocalParticipant = true
        self.isHold = false
        self.isInLobby = false
        self.accept = nil
        self.confirmDeny = nil
        self.confirmTitle = nil
        self.confirmAccept = nil
        self.deny = nil
    }

    init(participantInfoModel: ParticipantInfoModel,
         localizationProvider: LocalizationProviderProtocol,
         confirmTitle: String?,
         confirmAccept: String?,
         confirmDeny: String?,
         onAccept: (() -> Void)?,
         onDeny: (() -> Void)?
    ) {
        participantId = participantInfoModel.userIdentifier
        self.localizationProvider = localizationProvider
        self.displayName = participantInfoModel.displayName
        self.isMuted = participantInfoModel.isMuted
        self.isHold = participantInfoModel.status == .hold
        self.isLocalParticipant = false
        self.isInLobby = participantInfoModel.status == .inLobby
        self.accept = onAccept
        self.deny = onDeny
        self.confirmTitle = confirmTitle
        self.confirmDeny = confirmDeny
        self.confirmAccept = confirmAccept
    }

    func getParticipantViewData(from avatarViewManager: AvatarViewManagerProtocol) -> ParticipantViewData? {
        var participantViewData: ParticipantViewData?
        if isLocalParticipant {
            participantViewData = avatarViewManager.localParticipantViewData
        } else if let participantId = participantId {
            participantViewData = avatarViewManager.avatarStorage.value(forKey: participantId)
        }
        return participantViewData
    }

    func getCellDisplayName(with participantViewData: ParticipantViewData?) -> String {
        let name = getParticipantName(with: participantViewData)
        let isNameEmpty = name.trimmingCharacters(in: .whitespaces).isEmpty
        let displayName = isNameEmpty
        ? localizationProvider.getLocalizedString(.unnamedParticipant)
        : name
        return isLocalParticipant
        ? localizationProvider.getLocalizedString(.localeParticipantWithSuffix, displayName)
        : displayName
    }

    func getCellAccessibilityLabel(with participantViewData: ParticipantViewData?) -> String {
        let status = isInLobby ? localizationProvider.getLocalizedString(.participantListLobbyAction)
        : isHold ? getOnHoldString() :
        localizationProvider.getLocalizedString(isMuted ? .muted : .unmuted)
        return "\(getCellDisplayName(with: participantViewData)) \(status)"
    }

    func getParticipantName(with participantViewData: ParticipantViewData?) -> String {
        let name: String
        if let data = participantViewData, let renderDisplayName = data.displayName {
            let isRendererNameEmpty = renderDisplayName.trimmingCharacters(in: .whitespaces).isEmpty
            name = isRendererNameEmpty ? displayName : renderDisplayName
        } else {
            name = displayName
        }
        return name
    }

    func getOnHoldString() -> String {
        localizationProvider.getLocalizedString(.onHold)
    }
}

extension ParticipantsListCellViewModel {
     static func == (lhs: ParticipantsListCellViewModel,
                     rhs: ParticipantsListCellViewModel) -> Bool {
         lhs.participantId == rhs.participantId &&
         lhs.isMuted == rhs.isMuted &&
         lhs.isHold == rhs.isHold &&
         lhs.isLocalParticipant == rhs.isLocalParticipant &&
         lhs.displayName == rhs.displayName
     }
 }

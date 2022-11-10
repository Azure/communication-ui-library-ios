//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsListCellViewModel {
    let participantId: String?
    let isMuted: Bool
    let isHold: Bool
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
        self.isHold = false
    }

    init(participantInfoModel: ParticipantInfoModel,
         localizationProvider: LocalizationProviderProtocol) {
        participantId = participantInfoModel.userIdentifier
        self.localizationProvider = localizationProvider
        self.displayName = participantInfoModel.displayName
        self.isMuted = participantInfoModel.isMuted
        self.isHold = participantInfoModel.status == .hold
        self.isLocalParticipant = false
    }

    func getParticipantViewData(from avatarViewManager: AvatarViewManager) -> ParticipantViewData? {
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
        let status = isHold ? getOnHoldString() :
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

extension ParticipantsListCellViewModel: Equatable {
     static func == (lhs: ParticipantsListCellViewModel,
                     rhs: ParticipantsListCellViewModel) -> Bool {
         lhs.participantId == rhs.participantId &&
         lhs.isMuted == rhs.isMuted &&
         lhs.isHold == rhs.isHold &&
         lhs.isLocalParticipant == rhs.isLocalParticipant &&
         lhs.displayName == rhs.displayName
     }
 }

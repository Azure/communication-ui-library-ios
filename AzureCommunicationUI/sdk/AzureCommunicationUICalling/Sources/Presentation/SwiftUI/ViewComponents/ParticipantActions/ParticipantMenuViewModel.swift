//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantMenuViewModel: ObservableObject {
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private let onRemoveUser: (ParticipantInfoModel) -> Void
    private let capabilitiesManager: CapabilitiesManager

    private var participantInfoModel: ParticipantInfoModel?

    var isDisplayed: Bool
    var canRemove: Bool

    var items: [BaseDrawerItemViewModel] {
        guard let participantInfoModel = self.participantInfoModel else {
            return [
                BodyTextDrawerListItemViewModel(title: "N/A", accessibilityIdentifier: "N/A")
            ]
        }

        return [
            DrawerListItemViewModel(title: "Remove",
                                    accessibilityIdentifier: "Remove",
                                    action: {
                                        self.onRemoveUser(participantInfoModel)
                                    },
                                    startIcon: .personDelete,
                                    isEnabled: true)
        ]
    }

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol,
         capabilitiesManager: CapabilitiesManager,
         onRemoveUser: @escaping (ParticipantInfoModel) -> Void,
         isDisplayed: Bool) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.capabilitiesManager = capabilitiesManager
        self.canRemove = capabilitiesManager.hasCapability(
            capabilities: localUserState.capabilities,
            capability: ParticipantCapabilityType.removeParticipant)
        self.isDisplayed = false
        self.onRemoveUser = onRemoveUser
    }

    func update(localUserState: LocalUserState, isDisplayed: Bool, participantInfoModel: ParticipantInfoModel?) {
        self.participantInfoModel = participantInfoModel
        self.canRemove = capabilitiesManager.hasCapability(
            capabilities: localUserState.capabilities,
            capability: ParticipantCapabilityType.removeParticipant)
        // removeParticipantModel.isEnabled = canRemove
        self.isDisplayed = isDisplayed
    }
//
//    func showMenu(participantId: String,
//                  participantDisplayName: String) {
//        self.participantId = participantId
//        self.participantDisplayName = participantDisplayName
//    }

    func getParticipantName() -> String {
        return participantInfoModel?.displayName ?? ""
    }
}

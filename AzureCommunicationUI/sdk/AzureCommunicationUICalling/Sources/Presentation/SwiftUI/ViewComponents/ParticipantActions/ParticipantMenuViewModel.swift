//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantMenuViewModel: ObservableObject {
    // Odd this would come into a VM, probably should be the function it needs
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private let onRemoveUser: (ParticipantInfoModel) -> Void
    private let onMuteUser: (ParticipantInfoModel) -> Void

    // TADO: Should be a function (capability) -> Bool
    // Or the specific capability for the VM even better
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
         onMuteUser: @escaping (ParticipantInfoModel) -> Void,
         isDisplayed: Bool) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.capabilitiesManager = capabilitiesManager
        self.canRemove = capabilitiesManager.hasCapability(
            capabilities: localUserState.capabilities,
            capability: ParticipantCapabilityType.removeParticipant)

        // TADO: action should be in the lambda above4
        // and isEnabled should also be via the makeDrawerListItemViewModel()
//        removeParticipantModel.isEnabled = canRemove
//        removeParticipantModel.action = { [weak self] in
//            guard let self = self,
//                  let participantId = self.participantId else {
//                return
//            }
//            self.dispatch(.remoteParticipantsAction(.remove(participantId: participantId)))
//        }

        // TADO: We need to pass this via redux/init
        self.isDisplayed = false
        self.onRemoveUser = onRemoveUser
        self.onMuteUser = onMuteUser
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

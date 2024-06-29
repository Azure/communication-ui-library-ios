//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantMenuViewModel: ObservableObject {
    // Odd this would come into a VM, probably should be the function it needs
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let dispatch: ActionDispatch
    private let localizationProvider: LocalizationProviderProtocol

    // TADO: Should be a function (capability) -> Bool
    // Or the specific capability for the VM even better
    private let capabilitiesManager: CapabilitiesManager

    // TADO: Why Mutable?
    private var participantId: String?
    private var participantDisplayName: String?

    // Why Mutable?
    private var removeParticipantModel: DrawerListItemViewModel

    // Should display?
    private var isDisplayed: Bool

    var items: [DrawerListItemViewModel] {
        return [removeParticipantModel]
    }

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localUserState: LocalUserState,
         dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol,
         capabilitiesManager: CapabilitiesManager,
         isDisplayed: Bool) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.dispatch = dispatchAction
        self.localizationProvider = localizationProvider
        self.capabilitiesManager = capabilitiesManager

        let canRemove = capabilitiesManager.hasCapability(
            capabilities: localUserState.capabilities,
            capability: ParticipantCapabilityType.removeParticipant)

        removeParticipantModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .personDelete,
            title: localizationProvider.getLocalizedString(.callingViewParticipantMenuRemove),
            accessibilityIdentifier: AccessibilityIdentifier.callingViewParticipantMenuRemoveAccessibilityId.rawValue) {
        }

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
    }

    func update(localUserState: LocalUserState, isDisplayed: Bool) {
        let canRemove = capabilitiesManager.hasCapability(
            capabilities: localUserState.capabilities,
            capability: ParticipantCapabilityType.removeParticipant)
        removeParticipantModel.isEnabled = canRemove
        self.isDisplayed = isDisplayed
    }

    func showMenu(participantId: String,
                  participantDisplayName: String) {
        self.participantId = participantId
        self.participantDisplayName = participantDisplayName
    }

    func getParticipantName() -> String {
        return participantDisplayName ?? ""
    }
}

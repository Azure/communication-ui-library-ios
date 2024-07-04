//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantMenuViewModel: ObservableObject {
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private var participantId: String?
    private var participantDisplayName: String?
    private let dispatch: ActionDispatch
    private let localizationProvider: LocalizationProviderProtocol
    private let capabilitiesManager: CapabilitiesManager
    private var removeParticipantModel: DrawerListItemViewModel

    var items: [DrawerListItemViewModel] {
        return [removeParticipantModel]
    }

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localUserState: LocalUserState,
         dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol,
         capabilitiesManager: CapabilitiesManager) {
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
            accessibilityIdentifier: AccessibilityIdentifier.callingViewParticipantMenuRemoveAccessibilityId.rawValue,
            titleTrailingAccessoryView: CompositeIcon.none,
            action: {})

        removeParticipantModel.isEnabled = canRemove
        removeParticipantModel.action = { [weak self] in
            guard let self = self,
                  let participantId = self.participantId else {
                return
            }
            self.dispatch(.remoteParticipantsAction(.remove(participantId: participantId)))
        }
    }

    func update(localUserState: LocalUserState) {
        let canRemove = capabilitiesManager.hasCapability(
            capabilities: localUserState.capabilities,
            capability: ParticipantCapabilityType.removeParticipant)
        removeParticipantModel.isEnabled = canRemove
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

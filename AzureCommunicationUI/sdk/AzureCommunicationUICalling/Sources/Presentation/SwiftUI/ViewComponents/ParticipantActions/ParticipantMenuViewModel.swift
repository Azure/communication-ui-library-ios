//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal class ParticipantMenuViewModel: ObservableObject {
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private let onRemoveUser: (ParticipantInfoModel) -> Void
    private let capabilitiesManager: CapabilitiesManager
    private var participantInfoModel: ParticipantInfoModel?
    private var canRemove: Bool

    var isDisplayed: Bool
    @Published var items: [DrawerGenericItemViewModel] = []

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

        items = [DrawerGenericItemViewModel(title: localizationProvider.getLocalizedString(.participantRemove),
                                            accessibilityIdentifier: "Remove",
                                            action: rowTapped,
                                            startCompositeIcon: .personDelete,
                                            isEnabled: canRemove)]
    }

    private func rowTapped() {
        guard let pim = participantInfoModel else {
            return
        }
        self.onRemoveUser(pim)
    }

    func update(localUserState: LocalUserState, isDisplayed: Bool, participantInfoModel: ParticipantInfoModel?) {
        self.participantInfoModel = participantInfoModel
        self.canRemove = capabilitiesManager.hasCapability(
            capabilities: localUserState.capabilities,
            capability: ParticipantCapabilityType.removeParticipant)
        self.isDisplayed = isDisplayed

        items = [DrawerGenericItemViewModel(title: "Remove",
                                            accessibilityIdentifier: "Remove",
                                            action: rowTapped,
                                            startCompositeIcon: .personDelete,
                                            isEnabled: canRemove)]
    }

    func getParticipantName() -> String {
        return participantInfoModel?.displayName ?? ""
    }
}

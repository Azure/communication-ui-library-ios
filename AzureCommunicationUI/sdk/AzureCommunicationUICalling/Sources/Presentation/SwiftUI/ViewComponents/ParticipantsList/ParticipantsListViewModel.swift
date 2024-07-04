//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ParticipantsListViewModel: ObservableObject {
    @Published var drawerListItems: [DrawerListItemViewModel] = [TitleDrawerListItemViewModel(
        title: "Test",
        accessibilityIdentifier: "Test")]
    @Published var participantsList: [ParticipantsListCellViewModel] = []
    @Published var localParticipantsListCellViewModel: ParticipantsListCellViewModel

    private let localizationProvider: LocalizationProviderProtocol
    private var plusMoreParticipantCount: Int?

    var lastUpdateTimeStamp = Date()
    private var lastParticipantRole: ParticipantRoleEnum?

    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let dispatch: ActionDispatch
    var displayParticipantMenu: ((_ participantId: String, _ participantDisplayName: String) -> Void)?
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localUserState: LocalUserState,
         dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol) {
        self.compositeViewModelFactory = compositeViewModelFactory
        localParticipantsListCellViewModel =
        compositeViewModelFactory.makeLocalParticipantsListCellViewModel(localUserState: localUserState)
        self.dispatch = dispatchAction
        self.lastParticipantRole = localUserState.participantRole
        self.localizationProvider = localizationProvider
        self.isDisplayed = false
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                isDisplayed: Bool) {

        self.isDisplayed = isDisplayed
        if localParticipantsListCellViewModel.isMuted != (localUserState.audioState.operation == .off) {
            localParticipantsListCellViewModel =
            compositeViewModelFactory.makeLocalParticipantsListCellViewModel(localUserState: localUserState)
        }

        if lastUpdateTimeStamp != remoteParticipantsState.lastUpdateTimeStamp
           || self.lastParticipantRole != localUserState.participantRole {
            lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp
            self.lastParticipantRole = localUserState.participantRole

            let shouldilterOutLobbyUsers = shouldFilterOutLobbyUsers(participantRole: localUserState.participantRole)
            participantsList = remoteParticipantsState.participantInfoList
                .filter({ participant in
                    participant.status != .disconnected
                    && (!shouldilterOutLobbyUsers || participant.status != .inLobby)
                })
                .map {
                    compositeViewModelFactory.makeParticipantsListCellViewModel(participantInfoModel: $0)
                }
            // TADO: We need to interface this properly
            drawerListItems = participantsList.map {
                TitleDrawerListItemViewModel(title: $0.participantId ?? "N/A", accessibilityIdentifier: "")
            }
            drawerListItems.insert(BodyTextDrawerListItemViewModel(
                title: "In the call (#)",
                accessibilityIdentifier: "??"), at: 0)

            let plusMoreCount =
            remoteParticipantsState.totalParticipantCount - remoteParticipantsState.participantInfoList.count
            if plusMoreCount > 0 {
                self.plusMoreParticipantCount = plusMoreCount
            } else {
                self.plusMoreParticipantCount = nil
            }
        }
    }

    func sortedParticipants(with avatarManager: AvatarViewManager) -> [ParticipantsListCellViewModel] {
        // alphabetical order
        return ([localParticipantsListCellViewModel] + participantsList).sorted {
            let name = $0.getCellDisplayName(with: $0.getParticipantViewData(from: avatarManager))
            let nextName = $1.getCellDisplayName(with: $1.getParticipantViewData(from: avatarManager))
            return name.localizedCaseInsensitiveCompare(nextName) == .orderedAscending
        }
    }

    func plusMoreMenuItem() -> ParticipantsListCellViewModel? {
        if let plusMoreParticipantCount = self.plusMoreParticipantCount {
            return ParticipantsListCellViewModel(plusMoreCount: plusMoreParticipantCount,
                                                 localizationProvider: self.localizationProvider)
        }

        return nil
    }

    func admitAll() {
        dispatch(.remoteParticipantsAction(.admitAll))
    }

    func declineAll() {
        dispatch(.remoteParticipantsAction(.declineAll))
    }

    func admitParticipant(_ participantId: String) {
        dispatch(.remoteParticipantsAction(.admit(participantId: participantId)))
    }

    func declineParticipant(_ participantId: String) {
        dispatch(.remoteParticipantsAction(.decline(participantId: participantId)))
    }

    func getWaitingInLobby() -> String {
        self.localizationProvider.getLocalizedString(.participantListWaitingInLobby)
    }

    func getInTheCall() -> String {
        self.localizationProvider.getLocalizedString(.participantListInTheCall)
    }

    func getAdmitAllButtonText() -> String {
        self.localizationProvider.getLocalizedString(.participantListAdmitAll)
    }

    func getPlusMoreText() -> String {
        self.localizationProvider.getLocalizedString(.participantListPlusMore)
    }

    func getConfirmTitleAdmitParticipant() -> String {
        self.localizationProvider.getLocalizedString(.participantListConfirmTitleAdmitParticipant)
    }

    func getConfirmTitleAdmitAll() -> String {
        self.localizationProvider.getLocalizedString(.participantListConfirmTitleAdmitAll)
    }

    func getConfirmAdmit() -> String {
        self.localizationProvider.getLocalizedString(.participantListConfirmAdmit)
    }

    func getConfirmDecline() -> String {
        self.localizationProvider.getLocalizedString(.participantListConfirmDecline)
    }

    func openParticipantMenu(participantId: String, participantDisplayName: String) {
        self.displayParticipantMenu?(participantId, participantDisplayName)
    }

    private func shouldFilterOutLobbyUsers(participantRole: ParticipantRoleEnum?) -> Bool {
        return participantRole == nil
            || !(participantRole == .organizer
                 || participantRole == .presenter
                 || participantRole == .coOrganizer)
    }
}

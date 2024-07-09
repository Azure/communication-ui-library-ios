//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ParticipantsListViewModel: ObservableObject {
    @Published var drawerListItems: [BaseDrawerItemViewModel] = []

    private var lastParticipantRole: ParticipantRoleEnum?
    private let dispatch: ActionDispatch
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let onUserClicked: (ParticipantInfoModel) -> Void

    var isDisplayed: Bool
    var lastUpdateTimeStamp = Date()
    var displayParticipantMenu: ((_ participantId: String, _ participantDisplayName: String) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localUserState: LocalUserState,
         dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol,
         onUserClicked: @escaping (ParticipantInfoModel) -> Void
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.dispatch = dispatchAction
        self.lastParticipantRole = localUserState.participantRole
        self.localizationProvider = localizationProvider
        self.isDisplayed = false
        self.onUserClicked = onUserClicked

        // TADO: Delete,
        // localParticipantsListCellViewModel =
        // compositeViewModelFactory.makeLocalParticipantsListCellViewModel(localUserState: localUserState)
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                isDisplayed: Bool) {
        // Show this list if it's not displayed.
        self.isDisplayed = isDisplayed

        // Updating the local participant.
//
//        if localParticipantsListCellViewModel.isMuted != (localUserState.audioState.operation == .off) {
//            localParticipantsListCellViewModel =
//            compositeViewModelFactory.makeLocalParticipantsListCellViewModel(localUserState: localUserState)
//        }

        // If timestamp or lastRoleChanged
        if lastUpdateTimeStamp != remoteParticipantsState.lastUpdateTimeStamp
           || self.lastParticipantRole != localUserState.participantRole {
            lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp
            self.lastParticipantRole = localUserState.participantRole

            let shouldFilterOutLobbyUsers = shouldFilterOutLobbyUsers(
                participantRole: localUserState.participantRole)

            let localParticipant = [ParticipantsListCellViewModel(localUserState: localUserState,
                                                                 localizationProvider: localizationProvider)]

            let remoteParticipants = remoteParticipantsState.participantInfoList
                .filter { participant in
                    participant.status == .connected
                }.map {
                    ParticipantsListCellViewModel(participantInfoModel: $0,
                                                  localizationProvider: localizationProvider)
                }

            let lobbyParticipants = remoteParticipantsState.participantInfoList
                .filter { participant in
                    participant.status == .inLobby && !shouldFilterOutLobbyUsers
                }.map {
                    ParticipantsListCellViewModel(participantInfoModel: $0,
                                                  localizationProvider: localizationProvider)
                }

            var updatedDrawerListItems: [BaseDrawerItemViewModel]
                = localParticipant + remoteParticipants + lobbyParticipants

            // Header
            updatedDrawerListItems.insert(BodyTextDrawerListItemViewModel(
                title: "In the call (\(drawerListItems.count))", /* TADO: Is this correct Participants + 1 */
                accessibilityIdentifier: "??"), at: 0)

            drawerListItems = updatedDrawerListItems

            // Append + More item
            let plusMoreCount =
            remoteParticipantsState.totalParticipantCount - remoteParticipantsState.participantInfoList.count
            if plusMoreCount > 0 {
                drawerListItems.append(BodyTextDrawerListItemViewModel(
                    title: "Plus More \(plusMoreCount)",
                    accessibilityIdentifier: "PlusMore"
                ))
            }
        }
    }

    func sortedParticipants(with avatarManager: AvatarViewManager) -> [ParticipantsListCellViewModel] {
        // alphabetical order
        // TADO: Need to make sure participantList inludes local user
        return []
//        return ([localParticipantsListCellViewModel] /* + participantsList */).sorted {
//            let name = $0.getCellDisplayName(with: $0.getParticipantViewData(from: avatarManager))
//            let nextName = $1.getCellDisplayName(with: $1.getParticipantViewData(from: avatarManager))
//            return name.localizedCaseInsensitiveCompare(nextName) == .orderedAscending
//        }
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

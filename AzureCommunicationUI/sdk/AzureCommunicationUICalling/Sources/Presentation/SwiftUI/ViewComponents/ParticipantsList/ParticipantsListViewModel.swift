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
    private let avatarManager: AvatarViewManagerProtocol

    var isDisplayed: Bool
    var lastUpdateTimeStamp = Date()
    var displayParticipantMenu: ((_ participantId: String, _ participantDisplayName: String) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localUserState: LocalUserState,
         dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol,
         onUserClicked: @escaping (ParticipantInfoModel) -> Void,
         avatarManager: AvatarViewManagerProtocol
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.dispatch = dispatchAction
        self.lastParticipantRole = localUserState.participantRole
        self.localizationProvider = localizationProvider
        self.isDisplayed = false
        self.onUserClicked = onUserClicked
        self.avatarManager = avatarManager
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                isDisplayed: Bool) {

        self.isDisplayed = isDisplayed

        // If timestamp or lastRoleChanged
        if lastUpdateTimeStamp != remoteParticipantsState.lastUpdateTimeStamp
           || self.lastParticipantRole != localUserState.participantRole {
            lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp
            self.lastParticipantRole = localUserState.participantRole

            let shouldFilterOutLobbyUsers = shouldFilterOutLobbyUsers(
                participantRole: localUserState.participantRole)

            // Build the Local Participant "List"
            let localParticipant = [ParticipantsListCellViewModel(localUserState: localUserState,
                                                                 localizationProvider: localizationProvider)]

            // Grab the Remote Participants
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

            var participants = localParticipant + remoteParticipants

            participants = sortedParticipants(participants: participants, avatarManager: avatarManager)

            var updatedDrawerListItems: [BaseDrawerItemViewModel]
                = participants

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

    func sortedParticipants(
        participants: [ParticipantsListCellViewModel],
        avatarManager: AvatarViewManagerProtocol) -> [ParticipantsListCellViewModel] {
        return participants.sorted {
            let name = $0.getCellDisplayName(with: $0.getParticipantViewData(from: avatarManager))
            let nextName = $1.getCellDisplayName(with: $1.getParticipantViewData(from: avatarManager))
            return name.localizedCaseInsensitiveCompare(nextName) == .orderedAscending
        }
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

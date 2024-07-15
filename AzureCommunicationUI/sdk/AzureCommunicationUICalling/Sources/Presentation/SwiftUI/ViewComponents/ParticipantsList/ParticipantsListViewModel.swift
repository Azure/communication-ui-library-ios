//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ParticipantsListViewModel: ObservableObject {
    @Published var meetingParticipants: [BaseDrawerItemViewModel] = []
    @Published var lobbyParticipants: [BaseDrawerItemViewModel] = []
    @Published var meetingParticipantsTitle: BaseDrawerItemViewModel?
    @Published var lobbyParticipantsTitle: BaseDrawerItemViewModel?

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
            let localParticipantVM = [ParticipantsListCellViewModel(
                localUserState: localUserState,
                localizationProvider: localizationProvider)]

            // Grab the Remote Participants
            let remoteParticipantVMs = remoteParticipantsState.participantInfoList
                .filter { participant in
                    participant.status == .connected || participant.status == .hold
                }.map {
                    let participant = $0
                    return ParticipantsListCellViewModel(participantInfoModel: participant,
                                                         localizationProvider: localizationProvider,
                                                         confirmTitle: nil,
                                                         confirmAccept: nil,
                                                         confirmDeny: nil,
                                                         onAccept: {
                        self.onUserClicked(participant)
                    }, onDeny: {})
                }

            let lobbyParticipantVMs = remoteParticipantsState.participantInfoList
                .filter { participant in
                    participant.status == .inLobby && !shouldFilterOutLobbyUsers
                }.map {
                    let participant = $0
                    return ParticipantsListCellViewModel(participantInfoModel: participant,
                                                  localizationProvider: localizationProvider,
                                                         confirmTitle: String(
                                                            format: getConfirmTitleAdmitParticipant(),
                                                            $0.displayName),
                                                         confirmAccept: getConfirmAdmit(),
                                                         confirmDeny: getConfirmDecline(),
                                                         onAccept: {
                        self.admitParticipant(participant.userIdentifier)
                    }, onDeny: {
                        self.declineParticipant(participant.userIdentifier)
                    })
                }

            meetingParticipants = sortParticipants(
                participants: localParticipantVM + remoteParticipantVMs,
                avatarManager: avatarManager)

            meetingParticipantsTitle = BodyTextDrawerListItemViewModel(
                title: String(format: getInTheCall(), meetingParticipants.count),
                accessibilityIdentifier: "??")

            lobbyParticipants = sortParticipants(
                participants: lobbyParticipantVMs,
                avatarManager: avatarManager)

            lobbyParticipantsTitle = BodyTextWithActionDrawerListItemViewModel(
                title: String(format: getWaitingInLobby(), lobbyParticipants.count),
                accessibilityIdentifier: "??",
                actionText: getAdmitAllButtonText(),
                confirmTitle: getConfirmTitleAdmitAll(),
                confirmAccept: getConfirmAdmit(),
                confirmDeny: getConfirmDecline(),
                accept: { self.admitAll() },
                deny: { self.declineAll() }
            )

            // Append + More item
            let plusMoreCount =
            remoteParticipantsState.totalParticipantCount - remoteParticipantsState.participantInfoList.count
            if plusMoreCount > 0 {
                meetingParticipants.append(BodyTextDrawerListItemViewModel(
                    title: String(format: getPlusMoreText(), "\(plusMoreCount)"),
                    accessibilityIdentifier: "PlusMore"
                ))
            }
        }
    }

    func sortParticipants(
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

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

    // TADO, keep moving to drawerListItems, remove both of these
    @Published var participantsList: [ParticipantInfoModel] = []
    @Published var localParticipantsListCellViewModel: ParticipantsListCellViewModel

    private var plusMoreParticipantCount: Int?
    private var lastParticipantRole: ParticipantRoleEnum?
    private let dispatch: ActionDispatch
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol

    var isDisplayed: Bool
    var lastUpdateTimeStamp = Date()
    var displayParticipantMenu: ((_ participantId: String, _ participantDisplayName: String) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localUserState: LocalUserState,
         dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.dispatch = dispatchAction
        self.lastParticipantRole = localUserState.participantRole
        self.localizationProvider = localizationProvider
        self.isDisplayed = false

        // TADO: Delete,
        localParticipantsListCellViewModel =
        compositeViewModelFactory.makeLocalParticipantsListCellViewModel(localUserState: localUserState)
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                isDisplayed: Bool) {
        // Show this list if it's not displayed.
        self.isDisplayed = isDisplayed

        // Updating the local participant.
        if localParticipantsListCellViewModel.isMuted != (localUserState.audioState.operation == .off) {
            localParticipantsListCellViewModel =
            compositeViewModelFactory.makeLocalParticipantsListCellViewModel(localUserState: localUserState)
        }

        // If timestamp or lastRoleChanged
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

            // Remote participants
            drawerListItems = participantsList.map {
                ParticipantDrawerListItemViewModel(participantInfoModel: $0) {
                    // TADO: Click actions for a participant
                }
            }

            // Local Participants
            drawerListItems.append(ParticipantDrawerListItemViewModel(participantInfoModel: ParticipantInfoModel(
                displayName: localUserState.displayName ?? "Unknown User", /* TADO: Look up localized*/
                isSpeaking: false,
                isMuted: false, /* TADO: Wire up*/
                isRemoteUser: false,
                userIdentifier: localUserState.displayName ?? "UU", /* TADO: Wire up properly*/
                status: ParticipantStatus.connected, /* TADO: Safe Assumption?*/
                screenShareVideoStreamModel: nil,
                cameraVideoStreamModel: nil
            )) {

            })
            drawerListItems.insert(BodyTextDrawerListItemViewModel(
                title: "In the call (\(drawerListItems.count))", /* TADO: Is this correct Participants + 1 */
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
        // TADO: Need to make sure participantList inludes local user
        return ([localParticipantsListCellViewModel] /* + participantsList */).sorted {
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

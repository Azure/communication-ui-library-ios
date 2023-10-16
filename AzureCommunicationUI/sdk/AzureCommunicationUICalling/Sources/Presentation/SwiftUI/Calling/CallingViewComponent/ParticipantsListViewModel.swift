//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ParticipantsListViewModel: ObservableObject {
    @Published var participantsList: [ParticipantsListCellViewModel] = []
    @Published var localParticipantsListCellViewModel: ParticipantsListCellViewModel
    var lastUpdateTimeStamp = Date()
    private var lastParticipantRole: ParticipantRole?

    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let dispatch: ActionDispatch

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localUserState: LocalUserState,
         dispatchAction: @escaping ActionDispatch) {
        self.compositeViewModelFactory = compositeViewModelFactory
        localParticipantsListCellViewModel =
        compositeViewModelFactory.makeLocalParticipantsListCellViewModel(localUserState: localUserState)
        self.dispatch = dispatchAction
        self.lastParticipantRole = localUserState.participantRole
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState) {

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

    private func shouldFilterOutLobbyUsers(participantRole: ParticipantRole?) -> Bool {
        return participantRole == nil
            || !(participantRole == .organizer
                 || participantRole == .presenter
                 || participantRole == .coorganizer)
    }
}

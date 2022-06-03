//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCommon

protocol RemoteParticipantsManagerProtocol {
}

class RemoteParticipantsManager: RemoteParticipantsManagerProtocol {
    private let store: Store<AppState>
    private let eventsHandler: CallComposite.Events
    private let callingSDKWrapper: CallingSDKWrapperProtocol
    private let avatarViewManager: AvatarViewManager
    private var participantsLastUpdateTimeStamp = Date()
    private var participantsIds: Set<String> = []

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         callCompositeEventsHandler: CallComposite.Events,
         callingSDKWrapper: CallingSDKWrapperProtocol,
         avatarViewManager: AvatarViewManager) {
        self.store = store
        self.eventsHandler = callCompositeEventsHandler
        self.callingSDKWrapper = callingSDKWrapper
        self.avatarViewManager = avatarViewManager
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        guard participantsLastUpdateTimeStamp != state.remoteParticipantsState.lastUpdateTimeStamp else {
            return
        }

        participantsLastUpdateTimeStamp = state.remoteParticipantsState.lastUpdateTimeStamp
        let updatedParticipantsIds = Set(state.remoteParticipantsState.participantInfoList.map { $0.userIdentifier })

        let joinedParticipantsIds = updatedParticipantsIds.subtracting(participantsIds)
        let removedParticipantsIds = participantsIds.subtracting(updatedParticipantsIds)
        participantsIds = updatedParticipantsIds

        postRemoteParticipantsJoinedEvent(joinedParticipantsIds)
        postRemoteParticipantsRemovedEvent(removedParticipantsIds)
    }

    private func postRemoteParticipantsRemovedEvent(_ removedParticipantsIds: Set<String>) {
        // check if participants were removed from a call
        guard !removedParticipantsIds.isEmpty else {
            return
        }

        avatarViewManager.updateStorage(with: Array(removedParticipantsIds))
    }

    private func postRemoteParticipantsJoinedEvent(_ joinedParticipantsIds: Set<String>) {
        guard let didRemoteParticipantsJoin = eventsHandler.onRemoteParticipantJoined else {
            return
        }

        // check if new participants joined a call
        guard !joinedParticipantsIds.isEmpty else {
            return
        }

        let joinedParticipantsCommunicationIds = joinedParticipantsIds
            .compactMap { callingSDKWrapper.getRemoteParticipant($0)?.identifier }
        didRemoteParticipantsJoin(joinedParticipantsCommunicationIds)
    }
}

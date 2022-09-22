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
    private let eventsHandler: ChatComposite.Events
    private let chatSDKWrapper: ChatSDKWrapperProtocol
    private let avatarViewManager: AvatarViewManager
    private var participantsIds: Set<String> = []

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         chatCompositeEventsHandler: ChatComposite.Events,
         chatSDKWrapper: ChatSDKWrapperProtocol,
         avatarViewManager: AvatarViewManager) {
        self.store = store
        self.eventsHandler = chatCompositeEventsHandler
        self.chatSDKWrapper = chatSDKWrapper
        self.avatarViewManager = avatarViewManager
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        let updatedParticipantsIds = Set(state.participantsState.participantsInfoMap.keys)

//        let joinedParticipantsIds = updatedParticipantsIds.subtracting(participantsIds)
//        let removedParticipantsIds = participantsIds.subtracting(updatedParticipantsIds)
        participantsIds = updatedParticipantsIds

//        postRemoteParticipantsJoinedEvent(joinedParticipantsIds)
//        postRemoteParticipantsRemovedEvent(removedParticipantsIds)
    }

//    private func postRemoteParticipantsRemovedEvent(_ removedParticipantsIds: Set<String>) {
//        // check if participants were removed from a chat
//        guard !removedParticipantsIds.isEmpty else {
//            return
//        }
//
//        avatarViewManager.updateStorage(with: Array(removedParticipantsIds))
//    }
//
//    private func postRemoteParticipantsJoinedEvent(_ joinedParticipantsIds: Set<String>) {
//        guard let didRemoteParticipantsJoin = eventsHandler.onRemoteParticipantJoined else {
//            return
//        }
//
//        // check if new participants joined a chat
//        guard !joinedParticipantsIds.isEmpty else {
//            return
//        }
//
//        let joinedParticipantsCommunicationIds = joinedParticipantsIds
//            .compactMap { chatSDKWrapper.getRemoteParticipant($0)?.identifier }
//        didRemoteParticipantsJoin(joinedParticipantsCommunicationIds)
//    }
}

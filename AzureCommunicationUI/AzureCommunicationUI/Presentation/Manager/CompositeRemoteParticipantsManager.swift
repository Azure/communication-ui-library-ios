//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCommon

protocol RemoteParticipantsManager {
}

class CompositeRemoteParticipantsManager: RemoteParticipantsManager {
    private let store: Store<AppState>
    private let eventsHandler: CallCompositeEventsHandling
    private let callingSDKEventsHandling: CallingSDKEventsHandling
    private var participantsLastUpdateTimeStamp: Date
    private var participantsIds: Set<String>

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         callCompositeEventsHandler: CallCompositeEventsHandling,
         callingSDKEventsHandling: CallingSDKEventsHandling) {
        self.store = store
        self.eventsHandler = callCompositeEventsHandler
        self.callingSDKEventsHandling = callingSDKEventsHandling
        participantsIds = Set(store.state.remoteParticipantsState.participantInfoList.map { $0.userIdentifier })
        participantsLastUpdateTimeStamp = store.state.remoteParticipantsState.lastUpdateTimeStamp
        store.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    private func receive(_ state: AppState) {
        guard let didRemoteParticipantsJoin = eventsHandler.didRemoteParticipantsJoin,
              participantsLastUpdateTimeStamp != state.remoteParticipantsState.lastUpdateTimeStamp
        else { return }

        participantsLastUpdateTimeStamp = state.remoteParticipantsState.lastUpdateTimeStamp
        let updatedParticipantsIds = Set(state.remoteParticipantsState.participantInfoList.map { $0.userIdentifier })

        let joinedParticipantsIds = updatedParticipantsIds.subtracting(participantsIds)
        participantsIds = updatedParticipantsIds

        // check if new participants joined a call
        guard !joinedParticipantsIds.isEmpty
        else { return }

        let joinedParticipantsCommunicationIds = joinedParticipantsIds
            .compactMap { callingSDKEventsHandling.getParticipantCommunicationIdentifier(for: $0) }
        didRemoteParticipantsJoin(joinedParticipantsCommunicationIds)
    }
}

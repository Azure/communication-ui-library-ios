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
    private let eventsHandler: CallCompositeEventsHandling
    private let callingSDKWrapper: CallingSDKWrapper
    private var participantsLastUpdateTimeStamp: Date
    private var participantsIds: Set<String>

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         callCompositeEventsHandler: CallCompositeEventsHandling,
         callingSDKWrapper: CallingSDKWrapper) {
        self.store = store
        self.eventsHandler = callCompositeEventsHandler
        self.callingSDKWrapper = callingSDKWrapper
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
            .compactMap { callingSDKWrapper.getRemoteParticipant($0)?.identifier }
        didRemoteParticipantsJoin(joinedParticipantsCommunicationIds)
    }
}

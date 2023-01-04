//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon

import Combine
import Foundation

protocol AvatarViewManagerProtocol {
    var updatedId: PassthroughSubject<String?, Never> { get }
    var avatarStorage: MappedSequence<String, ParticipantViewData> { get }
    var localParticipantViewData: ParticipantViewData? { get }

    func set(remoteParticipantViewData: ParticipantViewData,
             for identifier: CommunicationIdentifier,
             completionHandler: ((Result<Void, SetParticipantViewDataError>) -> Void)?)
    func updateStorage(with removedParticipantsIds: [String])
}

class AvatarViewManager: AvatarViewManagerProtocol, ObservableObject {
    var updatedId = PassthroughSubject<String?, Never>()
    var localParticipantViewData: ParticipantViewData?
    private let store: Store<AppState, Action>
    private(set) var avatarStorage = MappedSequence<String, ParticipantViewData>()
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, Action>,
         localParticipantViewData: ParticipantViewData?) {
        self.store = store
        self.localParticipantViewData = localParticipantViewData
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state: state)
            }.store(in: &cancellables)
    }

    private func receive(state: AppState) {
        guard state.callingState.status == .disconnected ||
                state.errorState.errorCategory == .callState else {
            return
        }

        avatarStorage = MappedSequence<String, ParticipantViewData>()
    }

    func updateStorage(with removedParticipantsIds: [String]) {
        guard avatarStorage.count > 0 else {
            return
        }

        for id in removedParticipantsIds {
            avatarStorage.removeValue(forKey: id)
        }
    }

    func set(remoteParticipantViewData: ParticipantViewData,
             for identifier: CommunicationIdentifier,
             completionHandler: ((Result<Void, SetParticipantViewDataError>) -> Void)? = nil) {
        let participantsList = store.state.remoteParticipantsState.participantInfoList
        let idStringValue = identifier.rawId
        guard participantsList.contains(where: { $0.userIdentifier == idStringValue })
        else {
            completionHandler?(.failure(SetParticipantViewDataError.participantNotInCall))
            return
        }

        if avatarStorage.value(forKey: idStringValue) != nil {
            avatarStorage.removeValue(forKey: idStringValue)
        }
        avatarStorage.append(forKey: idStringValue,
                             value: remoteParticipantViewData)
        updatedId.send(idStringValue)
        objectWillChange.send()
        completionHandler?(.success(Void()))
    }
}

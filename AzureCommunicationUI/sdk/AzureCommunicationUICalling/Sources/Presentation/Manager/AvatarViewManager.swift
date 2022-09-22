//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import Combine

protocol AvatarViewManagerProtocol {
    var updatedId: PassthroughSubject<String?, Never> { get }
    var avatarStorage: MappedSequence<String, ParticipantViewData> { get }
    var participantViewData: CurrentValueSubject<ParticipantViewData?, Never> { get }

    func set(remoteParticipantViewData: ParticipantViewData,
             for identifier: CommunicationIdentifier,
             completionHandler: ((Result<Void, SetParticipantViewDataError>) -> Void)?)
    func updateStorage(with removedParticipantsIds: [String])
}

class AvatarViewManager: AvatarViewManagerProtocol, ObservableObject {
    var updatedId = PassthroughSubject<String?, Never>()
    var participantViewData: CurrentValueSubject<ParticipantViewData?, Never>
    private let store: Store<AppState>
    private(set) var avatarStorage = MappedSequence<String, ParticipantViewData>()
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         participantViewData: ParticipantViewData?) {
        self.store = store
        self.participantViewData = CurrentValueSubject<ParticipantViewData?, Never>(participantViewData)
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
        guard let idStringValue = identifier.stringValue,
              participantsList.contains(where: { $0.userIdentifier == idStringValue })
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
        completionHandler?(.success(Void()))
    }
}

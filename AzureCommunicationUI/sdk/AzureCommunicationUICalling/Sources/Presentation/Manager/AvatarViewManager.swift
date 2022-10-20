//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
@_spi(common) import AzureCommunicationUICommon
import Foundation
import Combine

protocol AvatarViewManagerProtocol {
    func set(remoteParticipantViewData: ParticipantViewData,
             for identifier: CommunicationIdentifier,
             completionHandler: ((Result<Void, SetParticipantViewDataError>) -> Void)?)
}

class AvatarViewManager: AvatarViewManagerProtocol, ObservableObject {
    @Published var updatedId: String?
    @Published private(set) var localOptions: LocalOptions?
    private let store: Store<AppState, Action>
    private(set) var avatarStorage = MappedSequence<String, ParticipantViewData>()
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, Action>,
         localOptions: LocalOptions?) {
        self.store = store
        self.localOptions = localOptions
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
        updatedId = idStringValue
        completionHandler?(.success(Void()))
    }
}

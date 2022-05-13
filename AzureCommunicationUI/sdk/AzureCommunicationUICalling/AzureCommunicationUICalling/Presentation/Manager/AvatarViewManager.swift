//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import Combine

protocol AvatarViewManagerProtocol {
    func setRemoteParticipantPersonaData(for identifier: CommunicationIdentifier,
                                         personaData: PersonaData) -> Result<Void, Error>
}

class AvatarViewManager: AvatarViewManagerProtocol, ObservableObject {
    private let store: Store<AppState>
    private(set) var avatarStorage = MappedSequence<String, PersonaData>()
    @Published var updatedId: String?
    @Published private(set) var localDataOptions: CommunicationUILocalDataOptions?
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         localDataOptions: CommunicationUILocalDataOptions?) {
        self.store = store
        self.localDataOptions = localDataOptions
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

        avatarStorage = MappedSequence<String, PersonaData>()
    }

    func removeLeftParticipants(_ leftParticipantsIds: [String]) {
        guard avatarStorage.count > 0 else {
            return
        }

        for id in leftParticipantsIds {
            avatarStorage.removeValue(forKey: id)
        }
    }

    func setRemoteParticipantPersonaData(for identifier: CommunicationIdentifier,
                                         personaData: PersonaData) -> Result<Void, Error> {
        guard let idStringValue = identifier.stringValue else {
            return .failure(CompositeError.remoteParticipantNotFound)
        }

        if avatarStorage.value(forKey: idStringValue) != nil {
            avatarStorage.removeValue(forKey: idStringValue)
        }
        avatarStorage.append(forKey: idStringValue,
                             value: personaData)
        updatedId = idStringValue
        return .success(Void())
    }
}

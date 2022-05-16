//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import Combine

protocol AvatarViewManagerProtocol {
    func setRemoteParticipantPersonaData(for identifier: CommunicationIdentifier,
                                         participantViewData: ParticipantViewData) -> Result<Void, Error>
}

class AvatarViewManager: AvatarViewManagerProtocol {
    private let store: Store<AppState>

    @Published private(set) var avatarStorage = MappedSequence<String, PersonaData>()
    @Published private(set) var localSettings: LocalSettings?
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         localSettings: LocalSettings?) {
        self.store = store
        self.localSettings = localSettings
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

    func setRemoteParticipantPersonaData(for identifier: CommunicationIdentifier,
                                         participantViewData: ParticipantViewData) -> Result<Void, Error> {
        guard let idStringValue = identifier.stringValue
        else {
            return .failure(CompositeError.remoteParticipantNotFound)
        }

        avatarStorage.append(forKey: idStringValue,
                             value: personaData)
        return .success(Void())
    }
}

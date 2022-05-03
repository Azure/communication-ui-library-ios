//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import Combine

protocol AvatarViewManagerProtocol {
    func getLocalPersonaData() -> PersonaData?
    func setRemoteParticipantPersonaData(for identifier: CommunicationIdentifier,
                                         personaData: PersonaData) -> Result<Bool, Error>
}

class AvatarViewManager: AvatarViewManagerProtocol {
    private let store: Store<AppState>
    private(set) var avatarStorage = MappedSequence<String, PersonaData>()
    private(set) var localDataOptions: CommunicationUILocalDataOptions?
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         localDataOptions: CommunicationUILocalDataOptions?) {
        self.store = store
        self.localDataOptions = localDataOptions
        store.$state
            .sink { [weak self] state in
                self?.receive(state: state)
            }.store(in: &cancellables)
    }

    private func receive(state: AppState) {
        guard state.callingState.status == .disconnected ||
                state.errorState.errorCategory == .callState
        else { return }

        avatarStorage = MappedSequence<String, PersonaData>()
    }

    func getLocalPersonaData() -> PersonaData? {
        guard let localPersona = localDataOptions?.localPersona else {
            return nil
        }

        return localPersona
    }

    func setRemoteParticipantPersonaData(for identifier: CommunicationIdentifier,
                                         personaData: PersonaData) -> Result<Bool, Error> {
        guard let idStringValue = identifier.stringValue
        else { return .failure(CompositeError.remoteParticipantNotFound) }

        avatarStorage.append(forKey: idStringValue,
                             value: personaData)
        return .success(true)
    }
}

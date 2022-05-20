//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import Combine

protocol AvatarViewManagerProtocol {
    func setRemoteParticipantViewData(
        _ participantViewData: ParticipantViewData,
        for identifier: CommunicationIdentifier) -> Result<Void, CommunicationUIErrorEvent>
}

class AvatarViewManager: AvatarViewManagerProtocol, ObservableObject {
    @Published var updatedId: String?
    @Published private(set) var localSettings: LocalSettings?
    private let store: Store<AppState>
    private(set) var avatarStorage = MappedSequence<String, ParticipantViewData>()
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

    func setRemoteParticipantViewData(
        _ participantViewData: ParticipantViewData,
        for identifier: CommunicationIdentifier) -> Result<Void, CommunicationUIErrorEvent> {
            let participantsList = store.state.remoteParticipantsState.participantInfoList
        guard let idStringValue = identifier.stringValue,
              participantsList.contains(where: { $0.userIdentifier == idStringValue })
        else {
            return .failure(CommunicationUIErrorEvent(code: CallCompositeErrorCode.remoteParticipantNotFound))
        }

        if avatarStorage.value(forKey: idStringValue) != nil {
            avatarStorage.removeValue(forKey: idStringValue)
        }
        avatarStorage.append(forKey: idStringValue,
                             value: participantViewData)
        updatedId = idStringValue
        return .success(Void())
    }
}

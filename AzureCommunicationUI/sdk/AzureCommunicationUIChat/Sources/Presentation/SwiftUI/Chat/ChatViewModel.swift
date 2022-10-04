//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    private let store: Store<AppState>
    private var cancellables = Set<AnyCancellable>()
    private var messageRepository: MessageRepositoryManagerProtocol
    private var repositoryUpdatedTimestamp: Date = .distantPast
    @Published var chatMessages: [ChatMessageInfoModel] = []

    init(store: Store<AppState>,
         messageRepository: MessageRepositoryManagerProtocol) {
        self.store = store
        self.messageRepository = messageRepository
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    // For testing
    func getInitialMessages() {
        store.dispatch(action: .repositoryAction(.fetchInitialMessagesTriggered))
    }

    func receive(_ state: AppState) {
        if self.repositoryUpdatedTimestamp < state.repositoryState.lastUpdatedTimestamp {
            self.repositoryUpdatedTimestamp = state.repositoryState.lastUpdatedTimestamp
            self.chatMessages = messageRepository.messages
        }
    }
}

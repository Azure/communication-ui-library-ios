//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let logger: Logger
    private let store: Store<ChatAppState, Action>

    private var cancellables = Set<AnyCancellable>()

    let topBarViewModel: TopBarViewModel
    let messageListViewModel: MessageListViewModel
    let bottomBarViewModel: BottomBarViewModel

    let typingParticipantsViewModel: TypingParticipantsViewModel

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         store: Store<ChatAppState, Action>) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger
        self.store = store

        self.topBarViewModel = compositeViewModelFactory
            .makeTopBarViewModel(dispatch: store.dispatch, participantsState: store.state.participantsState)
        self.messageListViewModel = compositeViewModelFactory.makeMessageListViewModel(dispatch: store.dispatch)
        self.bottomBarViewModel = compositeViewModelFactory.makeBottomBarViewModel(dispatch: store.dispatch)
        self.typingParticipantsViewModel = compositeViewModelFactory.makeTypingParticipantsViewModel()
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

    func receive(_ state: ChatAppState) {
        messageListViewModel.update(chatState: state.chatState, repositoryState: state.repositoryState)
        typingParticipantsViewModel.update(participantsState: state.participantsState)
        topBarViewModel.update(participantsState: state.participantsState)
        bottomBarViewModel.update(chatState: state.chatState)
    }
}

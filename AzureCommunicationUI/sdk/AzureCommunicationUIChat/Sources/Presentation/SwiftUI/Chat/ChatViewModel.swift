//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let logger: Logger
    private let store: Store<AppState>

    private var cancellables = Set<AnyCancellable>()

    let topBarViewModel: TopBarViewModel
    let threadViewModel: ThreadViewModel
    let messageInputViewModel: MessageInputViewModel

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         store: Store<AppState>) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger
        self.store = store

        self.topBarViewModel =
        compositeViewModelFactory.makeTopBarViewModel(
            participantsState: store.state.participantsState)
        self.threadViewModel =
        compositeViewModelFactory.makeThreadViewModel()
        self.messageInputViewModel =
        compositeViewModelFactory.makeMessageInputViewModel()

        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    func receive(_ state: AppState) {
    }
}

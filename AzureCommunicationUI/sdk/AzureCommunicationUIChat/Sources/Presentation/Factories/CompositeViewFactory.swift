//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol CompositeViewFactoryProtocol {
    func makeChatView() -> ChatView
}

struct CompositeViewFactory: CompositeViewFactoryProtocol {
    private let logger: Logger
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let avatarManager: AvatarViewManager

    init(logger: Logger,
         avatarManager: AvatarViewManager,
         compositeViewModelFactory: CompositeViewModelFactoryProtocol) {
        self.logger = logger
        self.avatarManager = avatarManager
        self.compositeViewModelFactory = compositeViewModelFactory
    }

    func makeChatView() -> ChatView {
        return ChatView(viewModel: compositeViewModelFactory.getChatViewModel(),
                        avatarManager: avatarManager)
    }
}

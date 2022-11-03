//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol CompositeViewFactoryProtocol {
    func makeChatView() -> ChatView
    func enter(status: AppStatus)
}

struct CompositeViewFactory: CompositeViewFactoryProtocol {
    private let logger: Logger
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol

    init(logger: Logger,
         compositeViewModelFactory: CompositeViewModelFactoryProtocol) {
        self.logger = logger
        self.compositeViewModelFactory = compositeViewModelFactory
    }

    func makeChatView() -> ChatView {
        return ChatView(viewModel: compositeViewModelFactory.getChatViewModel())
    }

    func enter(status: AppStatus) {
        compositeViewModelFactory.handleAppStatusChange(status)
    }
}

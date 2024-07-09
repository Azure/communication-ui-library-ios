//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol CompositeViewFactoryProtocol {
    func makeSetupView() -> SetupView
    func makeCallingView() -> CallingView
}

struct CompositeViewFactory: CompositeViewFactoryProtocol {
    private let logger: Logger
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let avatarManager: AvatarViewManagerProtocol
    private let videoViewManager: VideoViewManager
    private let chatButtonClick:(() -> Void)?
    private let listButtonClick:(() -> Void)?

    init(logger: Logger,
         avatarManager: AvatarViewManagerProtocol,
         videoViewManager: VideoViewManager,
         compositeViewModelFactory: CompositeViewModelFactoryProtocol,chatButtonClick:(() -> Void)? = nil,listButtonClick:(() -> Void)? = nil) {
        self.logger = logger
        self.avatarManager = avatarManager
        self.videoViewManager = videoViewManager
        self.compositeViewModelFactory = compositeViewModelFactory
        self.chatButtonClick=chatButtonClick
        self.listButtonClick=listButtonClick
    }

    func makeSetupView() -> SetupView {
        return SetupView(viewModel: compositeViewModelFactory.getSetupViewModel(),
                         viewManager: videoViewManager,
                         avatarManager: avatarManager)
    }

    func makeCallingView() -> CallingView {
        return CallingView(viewModel: compositeViewModelFactory.getCallingViewModel(chatButtonClick: chatButtonClick, listButtonClick: listButtonClick),
                           avatarManager: avatarManager,
                           viewManager: videoViewManager)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol CompositeViewFactory {
    func makeSetupView() -> SetupView
    func makeCallingView() -> CallingView
}

struct ACSCompositeViewFactory: CompositeViewFactory {
    private let logger: Logger
    private let compositeViewModelFactory: CompositeViewModelFactory
    private let avatarManager: AvatarManager
    private let videoViewManager: VideoViewManager

    init(logger: Logger,
         avatarManager: AvatarManager,
         videoViewManager: VideoViewManager,
         compositeViewModelFactory: CompositeViewModelFactory) {
        self.logger = logger
        self.avatarManager = avatarManager
        self.videoViewManager = videoViewManager
        self.compositeViewModelFactory = compositeViewModelFactory
    }

    func makeSetupView() -> SetupView {
        return SetupView(viewModel: compositeViewModelFactory.getSetupViewModel(),
                         avatarManager: avatarManager,
                         viewManager: videoViewManager)
    }

    func makeCallingView() -> CallingView {
        return CallingView(viewModel: compositeViewModelFactory.getCallingViewModel(),
                           avatarManager: avatarManager,
                           viewManager: videoViewManager)
    }
}

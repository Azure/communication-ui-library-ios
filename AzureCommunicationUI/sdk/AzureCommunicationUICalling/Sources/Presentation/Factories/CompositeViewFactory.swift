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
    private let customizationOptions: CustomizationOptions?
    private let injectedOverlayState: InjectedOverlayState

    init(logger: Logger,
         avatarManager: AvatarViewManagerProtocol,
         videoViewManager: VideoViewManager,
         customizationOptions: CustomizationOptions?,
         injectedOverlayState: InjectedOverlayState,
         compositeViewModelFactory: CompositeViewModelFactoryProtocol) {
        self.logger = logger
        self.avatarManager = avatarManager
        self.videoViewManager = videoViewManager
        self.compositeViewModelFactory = compositeViewModelFactory
        self.customizationOptions = customizationOptions
        self.injectedOverlayState = injectedOverlayState
    }

    func makeSetupView() -> SetupView {
        return SetupView(viewModel: compositeViewModelFactory.getSetupViewModel(),
                         viewManager: videoViewManager,
                         avatarManager: avatarManager)
    }

    func makeCallingView() -> CallingView {
        let headerButtonStates = customizationOptions?.customButtonViewData.filter {
            $0.state.type == .callingViewInfoHeader
        }.compactMap {
            $0.state
        }

        return CallingView(viewModel: compositeViewModelFactory.getCallingViewModel(),
                           injectedOverlayState: injectedOverlayState,
                           avatarManager: avatarManager,
                           viewManager: videoViewManager,
                           headerButtonStates: headerButtonStates ?? [])
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class LocalVideoViewModelMocking: LocalVideoViewModel {
    private let updateState: ((LocalUserState, PictureInPictureState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         updateState: ((LocalUserState, PictureInPictureState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   localizationProvider: localizationProvider,
                   dispatchAction: dispatchAction)
    }

    override func update(localUserState: LocalUserState, pipState: PictureInPictureState) {
        updateState?(localUserState, pipState)
    }
}

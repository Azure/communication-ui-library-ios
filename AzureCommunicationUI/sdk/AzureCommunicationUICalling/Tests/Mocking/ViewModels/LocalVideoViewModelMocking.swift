//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation

@testable import AzureCommunicationUICalling

class LocalVideoViewModelMocking: LocalVideoViewModel {
    private let updateState: ((LocalUserState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         updateState: ((LocalUserState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   localizationProvider: localizationProvider,
                   dispatchAction: dispatchAction)
    }

    override func update(localUserState: LocalUserState) {
        updateState?(localUserState)
    }
}

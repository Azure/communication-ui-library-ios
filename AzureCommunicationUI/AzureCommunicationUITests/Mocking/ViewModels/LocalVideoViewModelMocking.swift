//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class LocalVideoViewModelMocking: LocalVideoViewModel {
    private(set) var updateState: ((LocalUserState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatchAction: @escaping ActionDispatch,
         updateState: ((LocalUserState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   dispatchAction: dispatchAction)
    }

    override func update(localUserState: LocalUserState) {
        updateState?(localUserState)
    }
}

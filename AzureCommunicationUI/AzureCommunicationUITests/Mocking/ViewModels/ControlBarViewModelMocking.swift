//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class ControlBarViewModelMocking: ControlBarViewModel {
    private let updateState: ((LocalUserState, PermissionState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         localizationProvider: LocalizationProvider,
         dispatchAction: @escaping ActionDispatch,
         endCallConfirm: @escaping (() -> Void),
         localUserState: LocalUserState,
         updateState: ((LocalUserState, PermissionState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   localizationProvider: localizationProvider,
                   dispatchAction: dispatchAction,
                   endCallConfirm: endCallConfirm,
                   localUserState: localUserState)
    }

    override func update(localUserState: LocalUserState, permissionState: PermissionState) {
        updateState?(localUserState, permissionState)
    }
}

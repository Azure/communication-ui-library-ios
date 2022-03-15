//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class PreviewAreaViewModelMocking: PreviewAreaViewModel {
    private let updateState: ((LocalUserState, PermissionState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         dispatchAction: @escaping ActionDispatch,
         updateState: ((LocalUserState, PermissionState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   dispatchAction: dispatchAction)
    }

    override func update(localUserState: LocalUserState, permissionState: PermissionState) {
        updateState?(localUserState, permissionState)
    }
}

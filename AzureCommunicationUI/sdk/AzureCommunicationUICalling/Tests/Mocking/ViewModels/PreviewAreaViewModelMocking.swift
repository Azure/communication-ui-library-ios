//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class PreviewAreaViewModelMocking: PreviewAreaViewModel {
    private let updateState: ((LocalUserState, PermissionState, VisibilityState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         dispatchAction: @escaping ActionDispatch,
         updateState: ((LocalUserState, PermissionState, VisibilityState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   dispatchAction: dispatchAction,
                   localizationProvider: LocalizationProviderMocking())
    }

    override func update(localUserState: LocalUserState,
                         permissionState: PermissionState,
                         pipState: VisibilityState) {
        updateState?(localUserState, permissionState, pipState)
    }
}

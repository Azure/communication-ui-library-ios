//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class ControlBarViewModelMocking: ControlBarViewModel {
    private let updateState: ((LocalUserState, PermissionState, PictureInPictureState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         endCallConfirm: @escaping (() -> Void),
         localUserState: LocalUserState,
         updateState: ((LocalUserState, PermissionState, PictureInPictureState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   localizationProvider: localizationProvider,
                   dispatchAction: dispatchAction,
                   endCallConfirm: endCallConfirm,
                   localUserState: localUserState)
    }

    override func update(localUserState: LocalUserState,
                         permissionState: PermissionState,
                         callingState: CallingState,
                         defaultUserState: DefaultUserState,
                         pipState: PictureInPictureState) {
        updateState?(localUserState, permissionState, pipState)
    }
}

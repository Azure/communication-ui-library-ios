//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class SetupControlBarViewModelMocking: SetupControlBarViewModel {
    private let updateState: ((LocalUserState, PermissionState, CallingState) -> Void)?
    var updateIsJoinRequested: ((Bool) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatchAction: @escaping ActionDispatch,
         localUserState: LocalUserState,
         updateState: ((LocalUserState, PermissionState, CallingState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   dispatchAction: dispatchAction,
                   localUserState: localUserState,
                   localizationProvider: LocalizationProviderMocking())
    }

    override func update(localUserState: LocalUserState,
                         permissionState: PermissionState,
                         callingState: CallingState) {
        updateState?(localUserState, permissionState, callingState)
    }

    override func update(isJoinRequested: Bool) {
        updateIsJoinRequested?(isJoinRequested)
    }
}

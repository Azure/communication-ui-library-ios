//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class SetupControlBarViewModelMocking: SetupControlBarViewModel {
    private let updateState: ((LocalUserState, PermissionState, CallingState, ButtonViewDataState) -> Void)?
    var updateIsJoinRequested: ((Bool) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         dispatchAction: @escaping ActionDispatch,
         updatableOptionsManager: UpdatableOptionsManagerProtocol,
         localUserState: LocalUserState,
         buttonViewDataState: ButtonViewDataState,
         updateState: ((LocalUserState, PermissionState, CallingState, ButtonViewDataState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   dispatchAction: dispatchAction,
                   updatableOptionsManager: updatableOptionsManager,
                   localUserState: localUserState,
                   localizationProvider: LocalizationProviderMocking(),
                   audioVideoMode: .audioAndVideo,
                   setupScreenOptions: nil,
                   buttonViewDataState: buttonViewDataState)
    }

    override func update(localUserState: LocalUserState,
                         permissionState: PermissionState,
                         callingState: CallingState,
                         buttonViewDataState: ButtonViewDataState) {
        updateState?(localUserState, permissionState, callingState,
                     buttonViewDataState)
    }

    override func update(isJoinRequested: Bool) {
        updateIsJoinRequested?(isJoinRequested)
    }
}

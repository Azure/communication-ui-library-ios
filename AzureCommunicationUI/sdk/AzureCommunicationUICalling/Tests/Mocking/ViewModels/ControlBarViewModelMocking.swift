//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class ControlBarViewModelMocking: ControlBarViewModel {
    private let updateState: ((LocalUserState, PermissionState, VisibilityState, ButtonViewDataState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         onEndCallTapped: @escaping (() -> Void),
         localUserState: LocalUserState,
         updateState: ((LocalUserState, PermissionState, VisibilityState, ButtonViewDataState) -> Void)? = nil,
         leaveCallConfirmationMode: LeaveCallConfirmationMode = .alwaysEnabled,
         capabilitiesManager: CapabilitiesManager,
         buttonViewDataState: ButtonViewDataState) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   localizationProvider: localizationProvider,
                   dispatchAction: dispatchAction,
                   onEndCallTapped: onEndCallTapped,
                   localUserState: localUserState,
                   audioVideoMode: .audioAndVideo,
                   capabilitiesManager: capabilitiesManager,
                   controlBarOptions: nil,
                   buttonViewDataState: buttonViewDataState
        )
    }

    override func update(localUserState: LocalUserState,
                         permissionState: PermissionState,
                         callingState: CallingState,
                         visibilityState: VisibilityState,
                         navigationState: NavigationState,
                         buttonViewDataState: ButtonViewDataState) {
        updateState?(localUserState, permissionState, visibilityState, buttonViewDataState)
    }
}

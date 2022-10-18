//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation

@testable import AzureCommunicationUICalling

class ControlBarViewModelMocking: ControlBarViewModel {
    private let updateState: ((LocalUserState, PermissionState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
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

    override func update(localUserState: LocalUserState,
                         permissionState: PermissionState,
                         callingState: CallingState) {
        updateState?(localUserState, permissionState)
    }
}

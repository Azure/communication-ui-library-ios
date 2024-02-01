//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class InfoHeaderViewModelMocking: InfoHeaderViewModel {
    private let updateState: ((LocalUserState, RemoteParticipantsState, CallingState, VisibilityState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         dispatchAction: @escaping ActionDispatch,
         localUserState: LocalUserState,
         accessibilityProvider: AccessibilityProviderProtocol,
         updateState: ((LocalUserState, RemoteParticipantsState, CallingState, VisibilityState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   localUserState: localUserState,
                   localizationProvider: LocalizationProviderMocking(),
                   accessibilityProvider: accessibilityProvider,
                   dispatchAction: dispatchAction,
                   enableMultitasking: true,
                   enableSystemPiPWhenMultitasking: true)
    }

    override func update(localUserState: LocalUserState,
                         remoteParticipantsState: RemoteParticipantsState,
                         callingState: CallingState,
                         visibilityState: VisibilityState) {
        updateState?(localUserState, remoteParticipantsState, callingState, visibilityState)
    }
}

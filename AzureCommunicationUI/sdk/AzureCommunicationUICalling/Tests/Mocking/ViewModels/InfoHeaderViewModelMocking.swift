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
         localUserState: LocalUserState,
         accessibilityProvider: AccessibilityProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         updateState: ((LocalUserState, RemoteParticipantsState, CallingState, VisibilityState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   localUserState: localUserState,
                   localizationProvider: LocalizationProviderMocking(),
                   accessibilityProvider: accessibilityProvider,
                   dispatchAction: dispatchAction,
                   enableMultitasking: true,
                   enableSystemPipWhenMultitasking: true
                   /* <TIMER_TITLE_FEATURE> */
                   ,
                   callScreenInfoHeaderState:
                     CallScreenInfoHeaderState()
                   /* </TIMER_TITLE_FEATURE> */ )
    }

    override func update(localUserState: LocalUserState,
                         remoteParticipantsState: RemoteParticipantsState,
                         callingState: CallingState,
                         visibilityState: VisibilityState
                         /* <TIMER_TITLE_FEATURE> */ ,
                         callScreenInfoHeaderState: CallScreenInfoHeaderState?
                         /* </TIMER_TITLE_FEATURE> */ ) {
        updateState?(localUserState, remoteParticipantsState, callingState, visibilityState)
    }
}

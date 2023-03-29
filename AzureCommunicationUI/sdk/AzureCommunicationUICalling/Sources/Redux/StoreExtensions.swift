//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

typealias ActionDispatch = CommonActionDispatch<Action>

extension Store where State == AppState, Action == AzureCommunicationUICalling.Action {
    static func constructStore(
        logger: Logger,
        callingService: CallingServiceProtocol,
        displayName: String?,
        startWithCameraOn: Bool?,
        startWithMicrophoneOn: Bool?,
        skipSetupScreen: Bool?
    ) -> Store<AppState, Action> {
        let cameraState = startWithCameraOn
        ?? false ? LocalUserState.CameraState(operation: .on, device: .front, transmission: .local) :
        LocalUserState.CameraState(operation: .off, device: .front, transmission: .local)

        let audioState = startWithMicrophoneOn
        ?? false ? LocalUserState.AudioState(operation: .on, device: .receiverSelected) :
        LocalUserState.AudioState(operation: .off, device: .receiverSelected)

        let localUserState = LocalUserState(cameraState: cameraState, audioState: audioState, displayName: displayName)

        let callingState = skipSetupScreen ?? false ?
                CallingState(operationStatus: .bypassRequested): CallingState()
        let navigationStatus: NavigationStatus = skipSetupScreen ?? false ? .inCall : .setup
        let navigationState = NavigationState(status: navigationStatus)
        return .init(
            reducer: .appStateReducer(),
            middlewares: [
                .liveCallingMiddleware(
                    callingMiddlewareHandler: CallingMiddlewareHandler(
                        callingService: callingService,
                        logger: logger
                    )
                )
            ],
            state: AppState(callingState: callingState,
                            localUserState: localUserState,
                            navigationState: navigationState)
        )
    }
}

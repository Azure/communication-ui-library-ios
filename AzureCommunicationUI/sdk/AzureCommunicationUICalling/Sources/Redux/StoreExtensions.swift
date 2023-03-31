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
        ?? false ? DefaultUserState.CameraState.on : DefaultUserState.CameraState.off

        let audioState = startWithMicrophoneOn
        ?? false ? DefaultUserState.AudioState.on : DefaultUserState.AudioState.off

        let defaultUserState = DefaultUserState(
            cameraState: cameraState,
            audioState: audioState)

        let localUserState = LocalUserState(displayName: displayName)

        let callingState = skipSetupScreen ?? false ?
                CallingState(operationStatus: .skipSetupRequested): CallingState()
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
                            navigationState: navigationState,
                            defaultUserState: defaultUserState)
        )
    }
}

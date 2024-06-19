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
        skipSetupScreen: Bool?,
        callType: CompositeCallType
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
                CallingState(operationStatus: .skipSetupRequested) : CallingState()
        let navigationStatus: NavigationStatus = skipSetupScreen ?? false ? .inCall : .setup
        let navigationState = NavigationState(status: navigationStatus)
        return .init(
            reducer: .appStateReducer(),
            middlewares: [
                .liveCallingMiddleware(
                    callingMiddlewareHandler: CallingMiddlewareHandler(
                        callingService: callingService,
                        logger: logger,
                        callType: callType
                    )
                ),
                // Throttle filters commands that a user might dispatch frequently. I.e. to prevent smashing buttons
                // This can help ensure animations can play fully before the user triggers it again
                // The default delay
                // The keys can be grouped to throttle related actions
                    .throttleMiddleware {action in
                    switch action {
                        case .showSupportForm, .hideSupportForm:
                            return "SupportFormDrawer"
                        case .showMoreOptions, .hideMoreOptions:
                            return "MoreOptionsDrawer"
                        case .showAudioSelection, .hideAudioSelection:
                            return "AudioSelectionDrawer"
                        case .showEndCallConfirmation, .hideEndCallConfirmation:
                            return "EndCallDrawer"
                        case .showSupportShare, .hideSupportShare:
                            return "SupportShareDrawer"
                        default:
                            return nil
                        }
                    }
//                .throttleMiddleware(actions: [.showSupportForm,
//                                              .showMoreOptions,
//                                              .showAudioSelection,
//                                              .showEndCallConfirmation,
//                                              .showSupportShare])

            ],
            state: AppState(callingState: callingState,
                            localUserState: localUserState,
                            navigationState: navigationState,
                            defaultUserState: defaultUserState)
        )
    }
}

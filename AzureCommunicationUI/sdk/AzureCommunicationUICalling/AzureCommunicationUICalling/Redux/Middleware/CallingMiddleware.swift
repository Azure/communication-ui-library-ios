//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

func callingMiddleware(callingMiddlewareHandler actionHandler: CallingMiddlewareHandling)
-> Middleware<AppState> {

    return Middleware<AppState>(
        apply: { dispatch, getState in
            return { next in
                return { action in
                    switch action {
                    case .callingAction(let callingAction):
                        switch callingAction {
                        case .setupCall:
                            actionHandler.setupCall(state: getState(), dispatch: dispatch)
                        case .callStartRequested:
                            actionHandler.startCall(state: getState(), dispatch: dispatch)
                        case .callEndRequested:
                            actionHandler.endCall(state: getState(), dispatch: dispatch)
                        case .holdRequested:
                            actionHandler.holdCall(state: getState(), dispatch: dispatch)
                        case .resumeRequested:
                            actionHandler.resumeCall(state: getState(), dispatch: dispatch)
                        default:
                            break
                        }

                    case .localUserAction(let localUserAction):
                        switch localUserAction {
                        case .cameraPreviewOnTriggered:
                            actionHandler.requestCameraPreviewOn(state: getState(), dispatch: dispatch)
                        case .cameraOnTriggered:
                            actionHandler.requestCameraOn(state: getState(), dispatch: dispatch)
                        case .cameraOffTriggered:
                            actionHandler.requestCameraOff(state: getState(), dispatch: dispatch)
                        case .cameraSwitchTriggered:
                            actionHandler.requestCameraSwitch(state: getState(), dispatch: dispatch)
                        case .microphoneOffTriggered:
                            actionHandler.requestMicrophoneMute(state: getState(), dispatch: dispatch)
                        case .microphoneOnTriggered:
                            actionHandler.requestMicrophoneUnmute(state: getState(), dispatch: dispatch)
                        default:
                            break
                        }

                    case .permissionAction(let permissionAction):
                        switch permissionAction {
                        case .cameraPermissionGranted:
                            actionHandler.onCameraPermissionIsSet(state: getState(), dispatch: dispatch)
                        default:
                            break
                        }

                    case .lifecycleAction(let lifecycleAction):
                        switch lifecycleAction {
                        case .backgroundEntered:
                            actionHandler.enterBackground(state: getState(), dispatch: dispatch)
                        case .foregroundEntered:
                            actionHandler.enterForeground(state: getState(), dispatch: dispatch)
                        default:
                            break
                        }
                    case .audioSessionAction(.audioInterrupted):
                        actionHandler.audioSessionInterrupted(state: getState(), dispatch: dispatch)
                    default:
                        break
                    }
                    return next(action)
                }
            }
        }
    )
}

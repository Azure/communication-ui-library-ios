//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

struct CallingMiddleware: Middleware {
    private let actionHandler: CallingMiddlewareHandling

    init(callingMiddlewareHandler: CallingMiddlewareHandling) {
        self.actionHandler = callingMiddlewareHandler
    }

    func apply(dispatch: @escaping ActionDispatch,
               getState: @escaping () -> ReduxState?) -> (@escaping ActionDispatch) -> ActionDispatch {
        return { next in
            return { action in
                switch action {
                case _ as CallingAction.SetupCall:
                    actionHandler.setupCall(state: getState(), dispatch: dispatch)
                case _ as CallingAction.CallStartRequested:
                    actionHandler.startCall(state: getState(), dispatch: dispatch)
                case _ as CallingAction.CallEndRequested:
                    actionHandler.endCall(state: getState(), dispatch: dispatch)
                case _ as LocalUserAction.CameraPreviewOnTriggered:
                    actionHandler.requestCameraPreviewOn(state: getState(), dispatch: dispatch)
                case _ as LocalUserAction.CameraOnTriggered:
                    actionHandler.requestCameraOn(state: getState(), dispatch: dispatch)
                case _ as LocalUserAction.CameraOffTriggered:
                    actionHandler.requestCameraOff(state: getState(), dispatch: dispatch)
                case _ as LocalUserAction.CameraSwitchTriggered:
                    actionHandler.requestCameraSwitch(state: getState(), dispatch: dispatch)
                case _ as LocalUserAction.MicrophoneOffTriggered:
                    actionHandler.requestMicrophoneMute(state: getState(), dispatch: dispatch)
                case _ as LocalUserAction.MicrophoneOnTriggered:
                    actionHandler.requestMicrophoneUnmute(state: getState(), dispatch: dispatch)
                case _ as PermissionAction.CameraPermissionGranted:
                    actionHandler.onCameraPermissionIsSet(state: getState(), dispatch: dispatch)
                case _ as LifecycleAction.BackgroundEntered:
                    actionHandler.enterBackground(state: getState(), dispatch: dispatch)
                case _ as LifecycleAction.ForegroundEntered:
                    actionHandler.enterForeground(state: getState(), dispatch: dispatch)
                case _ as LifecycleAction.AudioInterruptionBegan:
                    actionHandler.holdCall(state: getState(), dispatch: dispatch)
                case _ as LifecycleAction.AudioInterruptionEnded:
                    actionHandler.resumeCall(state: getState(), dispatch: dispatch)

                default:
                    break
                }
                return next(action)
            }
        }
    }

}

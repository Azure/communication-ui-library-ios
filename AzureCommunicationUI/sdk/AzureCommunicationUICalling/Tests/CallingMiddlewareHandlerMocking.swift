//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class CallingMiddlewareHandlerMocking: CallingMiddlewareHandling {
    var requestCameraOnRetry: ((Bool) -> Void)?
    var setupCallWasCalled: ((Bool) -> Void)?
    var startCallWasCalled: ((Bool) -> Void)?
    var endCallWasCalled: ((Bool) -> Void)?
    var enterBackgroundCalled: ((Bool) -> Void)?
    var enterForegroundCalled: ((Bool) -> Void)?
    var cameraPermissionSetCalled: ((Bool) -> Void)?
    var cameraPermissionGrantedCalled: ((Bool) -> Void)?
    var requestCameraPreviewOnCalled: ((Bool) -> Void)?
    var requestCameraOnCalled: ((Bool) -> Void)?
    var requestCameraOffCalled: ((Bool) -> Void)?
    var requestCameraSwitchCalled: ((Bool) -> Void)?
    var requestMicMuteCalled: ((Bool) -> Void)?
    var requestMicUnmuteCalled: ((Bool) -> Void)?
    var requestHoldCalled: ((Bool) -> Void)?
    var requestResumeCalled: ((Bool) -> Void)?
    var willTerminateCalled: ((Bool) -> Void)?

    func requestCameraOnRetry(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestCameraOnRetry?(true)
        }
    }

    func setupCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            setupCallWasCalled?(true)
        }
    }

    func startCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            startCallWasCalled?(true)
        }
    }

    func endCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            endCallWasCalled?(true)
        }
    }

    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            enterBackgroundCalled?(true)
        }
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            enterForegroundCalled?(true)
        }
    }

    func onCameraPermissionIsSet(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            cameraPermissionSetCalled?(true)
        }
    }

    func cameraPermissionGranted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            cameraPermissionGrantedCalled?(true)
        }
    }

    func requestCameraPreviewOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestCameraPreviewOnCalled?(true)
        }
    }

    func requestCameraOn(
        state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
            Task {
                requestCameraOnCalled?(true)
            }
        }

    func requestCameraOff(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestCameraOffCalled?(true)
        }
    }

    func requestCameraSwitch(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestCameraSwitchCalled?(true)
        }
    }

    func requestMicrophoneMute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestMicMuteCalled?(true)
        }
    }

    func requestMicrophoneUnmute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestMicUnmuteCalled?(true)
        }
    }

    func holdCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestHoldCalled?(true)
        }
    }

    func resumeCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            requestResumeCalled?(true)
        }
    }

    func audioSessionInterrupted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {}
    }

    func willTerminate(state: AzureCommunicationUICalling.AppState, dispatch: @escaping AzureCommunicationUICalling.ActionDispatch) -> Task<Void, Never> {
        Task {
            willTerminateCalled?(true)
        }
    }
}

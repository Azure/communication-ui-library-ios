//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class CallingMiddlewareHandlerMocking: CallingMiddlewareHandling {
    var setupCallWasCalled: Bool = false
    var startCallWasCalled: Bool = false
    var endCallWasCalled: Bool = false
    var enterBackgroundCalled: Bool = false
    var enterForegroundCalled: Bool = false
    var cameraPermissionSetCalled: Bool = false
    var cameraPermissionGrantedCalled: Bool = false
    var requestCameraPreviewOnCalled: Bool = false
    var requestCameraOnCalled: Bool = false
    var requestCameraOffCalled: Bool = false
    var requestCameraSwitchCalled: Bool = false
    var requestMicMuteCalled: Bool = false
    var requestMicUnmuteCalled: Bool = false
    var requestHoldCalled: Bool = false
    var requestResumeCalled: Bool = false

    func setupCall(state: AppState, dispatch: @escaping ActionDispatch) {
        setupCallWasCalled = true
    }

    func startCall(state: AppState, dispatch: @escaping ActionDispatch) {
        startCallWasCalled = true
    }

    func endCall(state: AppState, dispatch: @escaping ActionDispatch) {
        endCallWasCalled = true
    }

    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) {
        enterBackgroundCalled = true
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) {
        enterForegroundCalled = true
    }

    func onCameraPermissionIsSet(state: AppState, dispatch: @escaping ActionDispatch) {
        cameraPermissionSetCalled = true
    }

    func cameraPermissionGranted(state: AppState, dispatch: @escaping ActionDispatch) {
        cameraPermissionGrantedCalled = true
    }

    func requestCameraPreviewOn(state: AppState, dispatch: @escaping ActionDispatch) {
        requestCameraPreviewOnCalled = true
    }

    func requestCameraOn(state: AppState, dispatch: @escaping ActionDispatch) {
        requestCameraOnCalled = true
    }

    func requestCameraOff(state: AppState, dispatch: @escaping ActionDispatch) {
        requestCameraOffCalled = true
    }

    func requestCameraSwitch(state: AppState, dispatch: @escaping ActionDispatch) {
        requestCameraSwitchCalled = true
    }

    func requestMicrophoneMute(state: AppState, dispatch: @escaping ActionDispatch) {
        requestMicMuteCalled = true
    }

    func requestMicrophoneUnmute(state: AppState, dispatch: @escaping ActionDispatch) {
        requestMicUnmuteCalled = true
    }

    func holdCall(state: AppState, dispatch: @escaping ActionDispatch) {
        requestHoldCalled = true
    }

    func resumeCall(state: AppState, dispatch: @escaping ActionDispatch) {
        requestResumeCalled = true
    }

    func audioSessionInterrupted(state: AppState, dispatch: @escaping ActionDispatch) {

    }
}

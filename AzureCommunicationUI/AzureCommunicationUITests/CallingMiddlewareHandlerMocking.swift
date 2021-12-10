//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class CallingMiddlewareHandlerMocking: CallingMiddlewareHandling {
    var setupCallWasCalled = false
    var startCallWasCalled = false
    var endCallWasCalled = false
    var enterBackgroundCalled = false
    var enterForegroundCalled = false
    var cameraPermissionSetCalled = false
    var cameraPermissionGrantedCalled = false
    var requestCameraPreviewOnCalled = false
    var requestCameraOnCalled = false
    var requestCameraOffCalled = false
    var requestCameraSwitchCalled = false
    var requestMicMuteCalled = false
    var requestMicUnmuteCalled = false

    func setupCall(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        setupCallWasCalled = true
    }

    func startCall(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        startCallWasCalled = true
    }

    func endCall(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        endCallWasCalled = true
    }

    func enterBackground(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        enterBackgroundCalled = true
    }

    func enterForeground(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        enterForegroundCalled = true
    }

    func onCameraPermissionIsSet(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        cameraPermissionSetCalled = true
    }

    func cameraPermissionGranted(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        cameraPermissionGrantedCalled = true
    }

    func requestCameraPreviewOn(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        requestCameraPreviewOnCalled = true
    }

    func requestCameraOn(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        requestCameraOnCalled = true
    }

    func requestCameraOff(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        requestCameraOffCalled = true
    }

    func requestCameraSwitch(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        requestCameraSwitchCalled = true
    }

    func requestMicrophoneMute(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        requestMicMuteCalled = true
    }

    func requestMicrophoneUnmute(state: ReduxState?, dispatch: @escaping ActionDispatch) {
        requestMicUnmuteCalled = true
    }
}

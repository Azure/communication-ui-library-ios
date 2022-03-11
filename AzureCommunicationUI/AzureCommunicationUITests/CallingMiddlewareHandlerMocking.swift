//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

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

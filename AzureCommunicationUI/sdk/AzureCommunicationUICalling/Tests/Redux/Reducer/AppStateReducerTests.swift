//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class AppStateReducerTests: XCTestCase {

    func test_appStateReducer_reducePermissionState_then_permissionReducerCalled_stateUpdated() {
        let oldPermissionState = PermissionState(audioPermission: .denied, cameraPermission: .denied)
        let expectedPermissionState = AppPermission.Status.granted
        let newPermissionState = PermissionState(audioPermission: expectedPermissionState, cameraPermission: expectedPermissionState)
        let mockSubReducer: Reducer<PermissionState, PermissionAction> = .mockReducer(outputState: newPermissionState)

        let state = getAppState(permissionState: oldPermissionState)
        let sut = getSUT(permissionReducer: mockSubReducer)
        let result = sut.reduce(state, Action.permissionAction(.audioPermissionNotAsked))    // Not asked should not cause the mocked state change

        XCTAssertEqual(result.permissionState.cameraPermission, expectedPermissionState)
        XCTAssertEqual(result.permissionState.audioPermission, expectedPermissionState)
    }

    func test_appStateReducer_reduceLocalUserState_then_localUserReducerCalled_stateUpdated() {
        let oldCameraState = LocalUserState.CameraState(operation: .off,
                                                        device: .front,
                                                        transmission: .local)
        let oldAudioState = LocalUserState.AudioState(operation: .off,
                                                      device: .receiverSelected)
        let oldLocalUserState = LocalUserState(cameraState: oldCameraState,
                                               audioState: oldAudioState,
                                               displayName: "",
                                               localVideoStreamIdentifier: "")
        let expectedCameraStatus = LocalUserState.CameraOperationalStatus.on
        let expectedCameraDeviceStatus = LocalUserState.CameraDeviceSelectionStatus.front
        let expectedMicStatus = LocalUserState.AudioOperationalStatus.on
        let expectedDisplayName = "IAmExpected"
        let expectedVideoStreamId = "IAmExpectedVideoId"
        let expectedCameraState = LocalUserState.CameraState(operation: expectedCameraStatus,
                                                             device: expectedCameraDeviceStatus,
                                                             transmission: .local)
        let expectedAudioState = LocalUserState.AudioState(operation: expectedMicStatus,
                                                           device: .receiverSelected)

        let newLocalUserState = LocalUserState(cameraState: expectedCameraState,
                                               audioState: expectedAudioState,
                                               displayName: expectedDisplayName,
                                               localVideoStreamIdentifier: expectedVideoStreamId)

        let mockSubReducer: Reducer<LocalUserState, LocalUserAction> = .mockReducer(outputState: newLocalUserState)

        let state = getAppState(localUserState: oldLocalUserState)
        let sut = getSUT(localUserReducer: mockSubReducer)
        let result = sut.reduce(state, Action.localUserAction(.cameraOffTriggered))

        XCTAssertEqual(result.localUserState.cameraState.operation, expectedCameraStatus)
        XCTAssertEqual(result.localUserState.cameraState.device, expectedCameraDeviceStatus)
        XCTAssertEqual(result.localUserState.audioState.operation, expectedMicStatus)
        XCTAssertEqual(result.localUserState.localVideoStreamIdentifier, expectedVideoStreamId)
        XCTAssertEqual(result.localUserState.displayName, expectedDisplayName)
    }

    func test_appStateReducer_reduceLifeCycleState_then_lifeCycleReducerCalled_stateUpdated() {
        let oldLifeCycleState = LifeCycleState(currentStatus: .background)
        let expectedState = AppStatus.foreground
        let newLifeCycleState = LifeCycleState(currentStatus: expectedState)
        let mockSubReducer: Reducer<LifeCycleState, LifecycleAction> = .mockReducer(outputState: newLifeCycleState)

        let state = getAppState(lifeCycleState: oldLifeCycleState)
        let sut = getSUT(lifeCycleReducer: mockSubReducer)
        let result = sut.reduce(state, Action.lifecycleAction(.backgroundEntered))

        XCTAssertEqual(result.lifeCycleState.currentStatus, expectedState)
    }

    func test_appStateReducer_reduceCallingState_then_callingStateReducerCalled_stateUpdated() {
        let oldState = CallingState(status: .connected)
        let expectedState = CallingStatus.disconnected
        let newState = CallingState(status: expectedState)
        let mockSubReducer: Reducer<CallingState, Action> = .mockReducer(outputState: newState)

        let state = getAppState(callingState: oldState)
        let sut = getSUT(callingReducer: mockSubReducer)
        let result = sut.reduce(state, Action.localUserAction(.cameraOnTriggered))

        XCTAssertEqual(result.callingState.status, expectedState)
    }

    func test_appStateReducer_reduceNaviState_then_naviStateReducerCalled_stateUpdated() {
        let oldState = NavigationState(status: .setup)
        let expectedState = NavigationState(status: .inCall)
        let mockSubReducer: Reducer<NavigationState, Action> = .mockReducer(outputState: expectedState)

        let state = getAppState(navigationState: oldState)
        let sut = getSUT(navigationReducer: mockSubReducer)
        let result = sut.reduce(state, Action.localUserAction(.cameraOnTriggered))

        XCTAssertEqual(result.navigationState, expectedState)
    }

    func test_appStateReducer_reduceErrorState_then_errorStateReducerCalled_stateUpdated() {
        let oldState = ErrorState()
        let expectedState = ErrorState(error: nil, errorCategory: .callState)
        let mockSubReducer: Reducer<ErrorState, Action> = .mockReducer(outputState: expectedState)

        let state = getAppState(errorState: oldState)
        let sut = getSUT(errorReducer: mockSubReducer)
        let result = sut.reduce(state, Action.localUserAction(.cameraOnTriggered))

        XCTAssertEqual(result.errorState, expectedState)
    }

    func test_appStateReducer_reduceDiagnosticState_then_diagnosticsStateCalled_stateUpdated() {
        let oldState = CallDiagnosticsState()
        let model = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: true)
        let expectedState = CallDiagnosticsState(mediaDiagnostic: model)
        let mockSubReducer: Reducer<CallDiagnosticsState, Action> = .mockReducer(outputState: expectedState)

        let state = getAppState(diagnosticsState: oldState)
        let sut = getSUT(diagnosticsReducer: mockSubReducer)
        let result = sut.reduce(state, Action.callDiagnosticAction(.media(diagnostic: model)))

        XCTAssertEqual(result.diagnosticsState, expectedState)
    }
}

extension AppStateReducerTests {
    func getSUT(permissionReducer: Reducer<PermissionState, PermissionAction> = .mockReducer(),
                localUserReducer: Reducer<LocalUserState, LocalUserAction> = .mockReducer(),
                lifeCycleReducer: Reducer<LifeCycleState, LifecycleAction> = .mockReducer(),
                audioSessionReducer: Reducer<AudioSessionState, AudioSessionAction> = .mockReducer(),
                callingReducer: Reducer<CallingState, Action> = .mockReducer(),
                navigationReducer: Reducer<NavigationState, Action> = .mockReducer(),
                errorReducer: Reducer<ErrorState, Action> = .mockReducer(),
                diagnosticsReducer: Reducer<CallDiagnosticsState, Action> = .mockReducer()
    ) -> Reducer<AppState, Action> {
        return Reducer<AppState, Action>.appStateReducer(
            permissionsReducer: permissionReducer,
            localUserReducer: localUserReducer,
            lifeCycleReducer: lifeCycleReducer,
            audioSessionReducer: audioSessionReducer,
            callingReducer: callingReducer,
            navigationReducer: navigationReducer,
            errorReducer: errorReducer,
            diagnosticsReducer: diagnosticsReducer
        )
    }

    func getAppState(callingState: CallingState = .init(),
                     permissionState: PermissionState = .init(),
                     localUserState: LocalUserState = .init(),
                     lifeCycleState: LifeCycleState = .init(),
                     navigationState: NavigationState = .init(),
                     remoteParticipantsState: RemoteParticipantsState = .init(),
                     errorState: ErrorState = .init(),
                     diagnosticsState: CallDiagnosticsState = .init()) -> AppState {
        return AppState(callingState: callingState,
                        permissionState: permissionState,
                        localUserState: localUserState,
                        lifeCycleState: lifeCycleState,
                        navigationState: navigationState,
                        remoteParticipantsState: remoteParticipantsState,
                        errorState: errorState,
                        diagnosticsState: diagnosticsState)
    }
}

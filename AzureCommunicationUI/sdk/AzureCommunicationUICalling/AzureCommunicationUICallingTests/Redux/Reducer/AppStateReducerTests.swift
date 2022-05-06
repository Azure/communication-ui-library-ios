//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class AppStateReducerTests: XCTestCase {

    // MARK: reduce
    func test_appStateReducer_reduce_when_notAppState_then_return() {
        let mockState = StateMocking()
        let sut = getSUT()
        let result = sut.reduce(mockState, ActionMocking())
        XCTAssert(result is StateMocking)
    }

    func test_appStateReducer_reducePermissionState_then_permissionReducerCalled_stateUpdated() {
        let oldPermissionState = PermissionState(audioPermission: .denied, cameraPermission: .denied)
        let mockSubReducer = ReducerMocking()
        let expectedPermissionState = AppPermission.Status.granted
        let newPermissionState = PermissionState(audioPermission: expectedPermissionState, cameraPermission: expectedPermissionState)
        mockSubReducer.outputState = newPermissionState

        let state = getAppState(permissionState: oldPermissionState)
        let sut = getSUT(permissionReducer: mockSubReducer)
        let result = sut.reduce(state, ActionMocking())
        guard let result = result as? AppState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(result.permissionState.cameraPermission, expectedPermissionState)
        XCTAssertEqual(result.permissionState.audioPermission, expectedPermissionState)
        XCTAssert(mockSubReducer.inputAction is ActionMocking)
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
        let mockSubReducer = ReducerMocking()
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
        mockSubReducer.outputState = newLocalUserState

        let state = getAppState(localUserState: oldLocalUserState)
        let sut = getSUT(localUserReducer: mockSubReducer)
        let result = sut.reduce(state, ActionMocking())
        guard let result = result as? AppState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(result.localUserState.cameraState.operation, expectedCameraStatus)
        XCTAssertEqual(result.localUserState.cameraState.device, expectedCameraDeviceStatus)
        XCTAssertEqual(result.localUserState.audioState.operation, expectedMicStatus)
        XCTAssertEqual(result.localUserState.localVideoStreamIdentifier, expectedVideoStreamId)
        XCTAssertEqual(result.localUserState.displayName, expectedDisplayName)
        XCTAssert(mockSubReducer.inputAction is ActionMocking)
    }

    func test_appStateReducer_reduceLifeCycleState_then_lifeCycleReducerCalled_stateUpdated() {
        let oldLifeCycleState = LifeCycleState(currentStatus: .background)
        let mockSubReducer = ReducerMocking()
        let expectedState = AppStatus.foreground

        let newLifeCycleState = LifeCycleState(currentStatus: expectedState)
        mockSubReducer.outputState = newLifeCycleState

        let state = getAppState(lifeCycleState: oldLifeCycleState)
        let sut = getSUT(lifeCycleReducer: mockSubReducer)
        let result = sut.reduce(state, ActionMocking())
        guard let result = result as? AppState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(result.lifeCycleState.currentStatus, expectedState)

        XCTAssert(mockSubReducer.inputAction is ActionMocking)
    }

    func test_appStateReducer_reduceCallingState_then_callingStateReducerCalled_stateUpdated() {
        let oldState = CallingState(status: .connected)
        let mockSubReducer = ReducerMocking()
        let expectedState = CallingStatus.disconnected

        let newState = CallingState(status: expectedState)
        mockSubReducer.outputState = newState

        let state = getAppState(callingState: oldState)
        let sut = getSUT(callingReducer: mockSubReducer)
        let result = sut.reduce(state, ActionMocking())
        guard let result = result as? AppState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(result.callingState.status, expectedState)

        XCTAssert(mockSubReducer.inputAction is ActionMocking)
    }

    func test_appStateReducer_reduceNaviState_then_naviStateReducerCalled_stateUpdated() {
        let oldState = NavigationState(status: .setup)
        let mockSubReducer = ReducerMocking()
        let expectedState = NavigationState(status: .inCall)

        mockSubReducer.outputState = expectedState

        let state = getAppState(navigationState: oldState)
        let sut = getSUT(navigationReducer: mockSubReducer)
        let result = sut.reduce(state, ActionMocking())
        guard let result = result as? AppState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(result.navigationState, expectedState)

        XCTAssert(mockSubReducer.inputAction is ActionMocking)
    }

    func test_appStateReducer_reduceErrorState_then_errorStateReducerCalled_stateUpdated() {
        let oldState = ErrorState()
        let mockSubReducer = ReducerMocking()
        let expectedState = ErrorState(error: nil, errorCategory: .callState)

        mockSubReducer.outputState = expectedState

        let state = getAppState(errorState: oldState)
        let sut = getSUT(errorReducer: mockSubReducer)
        let result = sut.reduce(state, ActionMocking())

        guard let result = result as? AppState else {
            XCTFail("Failed with state validation")
            return
        }

        XCTAssertEqual(result.errorState, expectedState)
        XCTAssert(mockSubReducer.inputAction is ActionMocking)
    }

    func test_appStateReducer_reduce_when_participantListUpdate_then_stateUpdated() {
        let userId = UUID().uuidString
        let infoModel = ParticipantInfoModelBuilder.get(participantIdentifier: userId,
                                                        videoStreamId: "",
                                                        displayName: "",
                                                        isSpeaking: false,
                                                        recentSpeakingStamp: Date())
        let action = ParticipantListUpdated(participantsInfoList: [infoModel])
        let sut = getSUT()
        let state = getAppState()
        let result = sut.reduce(state, action)
        guard let result = result as? AppState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(result.remoteParticipantsState.participantInfoList.count, 1)
        XCTAssertEqual(result.remoteParticipantsState.participantInfoList.first?.userIdentifier, userId)
    }

    func test_appStateReducer_reduce_when_StatusErrorAndCallReset_then_remoteParticipantStateCleanup() {
        let userId = UUID().uuidString
        let action = ErrorAction.StatusErrorAndCallReset(error: CommunicationUIErrorEvent(code: "",
                                                                            error: nil))
        let sut = getSUT()
        let participant = ParticipantInfoModel(displayName: "displayname",
                                               isSpeaking: false,
                                               isMuted: true,
                                               isRemoteUser: false,
                                               userIdentifier: userId,
                                               recentSpeakingStamp: Date(),
                                               screenShareVideoStreamModel: nil,
                                               cameraVideoStreamModel: nil)
        let remoteParticipantsState = RemoteParticipantsState(participantInfoList: [participant])
        let state = getAppState(remoteParticipantsState: remoteParticipantsState)
        let result = sut.reduce(state, action)
        guard let result = result as? AppState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(result.remoteParticipantsState.participantInfoList.count, 0)
    }
}

extension AppStateReducerTests {
    func getSUT(permissionReducer: Reducer = ReducerMocking(),
                localUserReducer: Reducer = ReducerMocking(),
                lifeCycleReducer: Reducer = ReducerMocking(),
                callingReducer: Reducer = ReducerMocking(),
                navigationReducer: Reducer = ReducerMocking(),
                errorReducer: Reducer = ReducerMocking()) -> AppStateReducer {
        return AppStateReducer(permissionReducer: permissionReducer,
                               localUserReducer: localUserReducer,
                               lifeCycleReducer: lifeCycleReducer,
                               callingReducer: callingReducer,
                               navigationReducer: navigationReducer,
                               errorReducer: errorReducer)
    }

    func getAppState(callingState: CallingState = .init(),
                     permissionState: PermissionState = .init(),
                     localUserState: LocalUserState = .init(),
                     lifeCycleState: LifeCycleState = .init(),
                     navigationState: NavigationState = .init(),
                     remoteParticipantsState: RemoteParticipantsState = .init(),
                     errorState: ErrorState = .init()) -> AppState {
        return AppState(callingState: callingState,
                        permissionState: permissionState,
                        localUserState: localUserState,
                        lifeCycleState: lifeCycleState,
                        navigationState: navigationState,
                        remoteParticipantsState: remoteParticipantsState,
                        errorState: errorState)
    }
}

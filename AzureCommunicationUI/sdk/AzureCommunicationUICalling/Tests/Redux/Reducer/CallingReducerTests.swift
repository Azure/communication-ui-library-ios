//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallingReducerTests: XCTestCase {
    func test_callingReducer_reduce_when_callingActionStateUpdated_then_stateUpdated() {
        let expectedState = CallingStatus.connected
        let state = CallingState(status: .disconnected)
        let action = Action.callingAction(.stateUpdated(status: expectedState))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.status, expectedState)
    }

    func test_callingReducer_reduce_when_unhandledAction_then_stateNotUpdate() {
        let expectedState = CallingStatus.disconnected
        let state = CallingState(status: expectedState)
        let action = Action.permissionAction(.audioPermissionNotAsked)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.status, expectedState)
    }

    func test_callingReducer_reduce_when_callingActionRecordingStateUpdatedTrue_then_recordingStateUpdatedTrue() {
        let expectedState = CallingState(status: .connected,
                                         isRecordingActive: true,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .connected,
                                 isRecordingActive: false,
                                 isTranscriptionActive: false)
        let action = Action.callingAction(.recordingStateUpdated(isRecordingActive: true))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_callingActionRecordingStateUpdatedFalse_then_recordingStateUpdatedFalse() {
        let expectedState = CallingState(status: .connected,
                                         isRecordingActive: false,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .connected,
                                 isRecordingActive: true,
                                 isTranscriptionActive: false)
        let action = Action.callingAction(.recordingStateUpdated(isRecordingActive: false))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_callingActionTranscriptionStateUpdatedTrue_then_transcriptionStateUpdatedTrue() {
        let expectedState = CallingState(status: .connected,
                                         isRecordingActive: false,
                                         isTranscriptionActive: true)
        let state = CallingState(status: .connected,
                                 isRecordingActive: false,
                                 isTranscriptionActive: false)
        let action = Action.callingAction(.transcriptionStateUpdated(isTranscriptionActive: true))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_callingActionTranscriptionStateUpdatedFalse_then_transcriptionStateUpdatedFalse() {
        let expectedState = CallingState(status: .connected,
                                         isRecordingActive: false,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .connected,
                                 isRecordingActive: false,
                                 isTranscriptionActive: true)
        let action = Action.callingAction(.transcriptionStateUpdated(isTranscriptionActive: false))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_statusErrorAndCallReset_then_CallingStateReset() {
        let expectedState = CallingState(status: .none,
                                         isRecordingActive: false,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .connected,
                                 isRecordingActive: true,
                                 isTranscriptionActive: true)
        let action = Action.errorAction(.statusErrorAndCallReset(internalError: .callDenied,
                                                         error: nil))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_callEvictionErrorAndCallReset_then_CallingStateReset() {
        let expectedState = CallingState(status: .none,
                                         isRecordingActive: false,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .disconnected,
                                 isRecordingActive: true,
                                 isTranscriptionActive: true)
        let action = Action.errorAction(.statusErrorAndCallReset(internalError: .callEvicted,
                                                         error: nil))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_callDeniedErrorAndCallReset_then_CallingStateReset() {
        let expectedState = CallingState(status: .none,
                                         isRecordingActive: false,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .disconnected,
                                 isRecordingActive: false,
                                 isTranscriptionActive: false)
        let action = Action.errorAction(.statusErrorAndCallReset(internalError: .callDenied,
                                                         error: nil))
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState, expectedState)
    }
}

extension CallingReducerTests {
    private func makeSUT() -> Reducer<CallingState, Action> {
        return .liveCallingReducer
    }
}

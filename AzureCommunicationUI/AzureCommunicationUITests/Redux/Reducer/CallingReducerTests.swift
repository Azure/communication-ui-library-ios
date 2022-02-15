//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class CallingReducerTests: XCTestCase {
    func test_callingReducer_reduce_when_notCallingState_then_return() {
        let state = StateMocking()
        let action = CallingAction.StateUpdated(status: .connected)
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssert(resultState is StateMocking)
    }

    func test_callingReducer_reduce_when_callingActionStateUpdated_then_stateUpdated() {
        let expectedState = CallingStatus.connected
        let state = CallingState(status: .disconnected)
        let action = CallingAction.StateUpdated(status: expectedState)
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        guard let resultState = resultState as? CallingState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState.status, expectedState)
    }

    func test_callingReducer_reduce_when_mockingAction_then_stateNotUpdate() {
        let expectedState = CallingStatus.disconnected
        let state = CallingState(status: expectedState)
        let action = ActionMocking()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        guard let resultState = resultState as? CallingState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState.status, expectedState)
    }

    func test_callingReducer_reduce_when_callingActionRecordingStateUpdatedTrue_then_recordingStateUpdatedTrue() {
        let expectedState = CallingState(status: .connected,
                                         isRecordingActive: true,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .connected,
                                 isRecordingActive: false,
                                 isTranscriptionActive: false)
        let action = CallingAction.RecordingStateUpdated(isRecordingActive: true)
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        guard let resultState = resultState as? CallingState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_callingActionRecordingStateUpdatedFalse_then_recordingStateUpdatedFalse() {
        let expectedState = CallingState(status: .connected,
                                         isRecordingActive: false,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .connected,
                                 isRecordingActive: true,
                                 isTranscriptionActive: false)
        let action = CallingAction.RecordingStateUpdated(isRecordingActive: false)
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        guard let resultState = resultState as? CallingState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_callingActionTranscriptionStateUpdatedTrue_then_transcriptionStateUpdatedTrue() {
        let expectedState = CallingState(status: .connected,
                                         isRecordingActive: false,
                                         isTranscriptionActive: true)
        let state = CallingState(status: .connected,
                                 isRecordingActive: false,
                                 isTranscriptionActive: false)
        let action = CallingAction.TranscriptionStateUpdated(isTranscriptionActive: true)
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        guard let resultState = resultState as? CallingState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_callingActionTranscriptionStateUpdatedFalse_then_transcriptionStateUpdatedFalse() {
        let expectedState = CallingState(status: .connected,
                                         isRecordingActive: false,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .connected,
                                 isRecordingActive: false,
                                 isTranscriptionActive: true)
        let action = CallingAction.TranscriptionStateUpdated(isTranscriptionActive: false)
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        guard let resultState = resultState as? CallingState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState, expectedState)
    }

    func test_callingReducer_reduce_when_callingViewLaunched_then_cleanup() {
        let expectedState = CallingState(status: .none,
                                         isRecordingActive: false,
                                         isTranscriptionActive: false)
        let state = CallingState(status: .connected,
                                 isRecordingActive: true,
                                 isTranscriptionActive: true)
        let action = CallingViewLaunched()
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        guard let resultState = resultState as? CallingState else {
            XCTFail("Failed with state validation")
            return
        }
        XCTAssertEqual(resultState, expectedState)
    }
}

extension CallingReducerTests {
    private func getSUT() -> CallingReducer {
        return CallingReducer()
    }
}

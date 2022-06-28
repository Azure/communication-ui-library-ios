//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import XCTest
import Combine
@testable import AzureCommunicationUICalling

class CallingMiddlewareTests: XCTestCase {

    var mockMiddlewareHandler: CallingMiddlewareHandlerMocking!
    var mockMiddleware: Middleware<AppState>!

    override func setUp() {
        super.setUp()
        mockMiddlewareHandler = CallingMiddlewareHandlerMocking()
        mockMiddleware = .liveCallingMiddleware(callingMiddlewareHandler: mockMiddlewareHandler)
    }

    func test_callingMiddleware_apply_when_setupCallCallingAction_then_handlerSetupCallBeingCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.callingAction(.setupCall))

        XCTAssertTrue(mockMiddlewareHandler.setupCallWasCalled)
    }

    func test_callingMiddleware_apply_when_startCallCallingAction_then_handlerStartCallBeingCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.callingAction(.callStartRequested))

        XCTAssertTrue(mockMiddlewareHandler.startCallWasCalled)
    }

    func test_callingMiddleware_apply_when_endCallCallingAction_then_handlerEndCallBeingCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.callingAction(.callEndRequested))

        XCTAssertTrue(mockMiddlewareHandler.endCallWasCalled)
    }

    func test_callingMiddleware_apply_when_requestMicrophoneOffLocalUserAction_then_handlerRequestMicMuteCalled() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.localUserAction(.microphoneOffTriggered))

        XCTAssertTrue(mockMiddlewareHandler.requestMicMuteCalled)
    }

    func test_callingMiddleware_apply_when_requestMicrophoneOnLocalUserAction_then_handlerRequestMicUnmuteCalled() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.localUserAction(.microphoneOnTriggered))

        XCTAssertTrue(mockMiddlewareHandler.requestMicUnmuteCalled)
    }

    func test_callingMiddleware_apply_when_cameraPermissionGranted_then_handlerOnCameraPermissionIsSet() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.permissionAction(.cameraPermissionGranted))

        XCTAssertTrue(mockMiddlewareHandler.cameraPermissionSetCalled)
    }

    func test_callingMiddleware_apply_when_requestCameraPreviewOn_then_handlerRequestCameraPreviewOnCalled() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.localUserAction(.cameraPreviewOnTriggered))

        XCTAssertTrue(mockMiddlewareHandler.requestCameraPreviewOnCalled)
    }

    func test_callingMiddleware_apply_when_requestCameraOnLocalUserAction_then_handlerRequestCameraOnCalled() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.localUserAction(.cameraOnTriggered))

        XCTAssertTrue(mockMiddlewareHandler.requestCameraOnCalled)
    }

    func test_callingMiddleware_apply_when_requestCameraOffLocalUserAction_then_handlerRequestCameraOffCalled() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.localUserAction(.cameraOffTriggered))

        XCTAssertTrue(mockMiddlewareHandler.requestCameraOffCalled)
    }

    func test_callingMiddleware_apply_when_holdCallRequestAction_then_handlerHoldCall() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.callingAction(.holdRequested))

        XCTAssertTrue(mockMiddlewareHandler.requestHoldCalled)
    }

    func test_callingMiddleware_apply_when_resumeCallRequestAction_then_handlerResumeCall() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        middlewareDispatch(getEmptyDispatch())(.callingAction(.resumeRequested))

        XCTAssertTrue(mockMiddlewareHandler.requestResumeCalled)
    }

    func test_callingMiddleware_apply_when_requestCameraOn_then_nextActionDispatchCameraOnTriggered() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()

        let action = Actions.localUserAction(.cameraOnTriggered)
        let expectation = XCTestExpectation(description: "Verify is same action Type")
        let nextDispatch = getAssertSameActionDispatch(action: action, expectation: expectation)
        middlewareDispatch(nextDispatch)(action)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_requestMicOn_then_nextActionDispatchMicrophoneOnTriggered() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()

        let action = Actions.localUserAction(.microphoneOnTriggered)
        let expectation = XCTestExpectation(description: "Verify is same action Type")
        let nextDispatch = getAssertSameActionDispatch(action: action, expectation: expectation)
        middlewareDispatch(nextDispatch)(action)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_enterForeground_then_nextActionDispatchEnterForeground() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()

        let action = Actions.lifecycleAction(.foregroundEntered)
        let expectation = XCTestExpectation(description: "Verify is same action Type")
        let nextDispatch = getAssertSameActionDispatch(action: action, expectation: expectation)
        middlewareDispatch(nextDispatch)(action)
        wait(for: [expectation], timeout: 1)
    }

}

extension CallingMiddlewareTests {

    private func getEmptyState() -> AppState {
        return AppState()
    }
    private func getEmptyDispatch() -> ActionDispatch {
        return { _ in }
    }

    private func getEmptyCallingMiddlewareFunction() -> (@escaping ActionDispatch) -> ActionDispatch {
        return mockMiddleware.apply(getEmptyDispatch(), getEmptyState)
    }

    private func getAssertSameActionDispatch(action: Actions, expectation: XCTestExpectation) -> ActionDispatch {
        return { nextAction in
            XCTAssertTrue(type(of: action) == type(of: nextAction))
            expectation.fulfill()
        }
    }
}

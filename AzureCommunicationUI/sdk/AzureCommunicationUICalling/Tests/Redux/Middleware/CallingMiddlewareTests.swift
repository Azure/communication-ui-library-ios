//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

import XCTest
import Combine
@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class CallingMiddlewareTests: XCTestCase {

    var mockMiddlewareHandler: CallingMiddlewareHandlerMocking!

    override func setUp() {
        super.setUp()
        mockMiddlewareHandler = CallingMiddlewareHandlerMocking()
    }

    override func tearDown() {
        super.tearDown()
        mockMiddlewareHandler = nil
    }

    func test_callingMiddleware_apply_when_setupCallCallingAction_then_handlerSetupCallBeingCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "setupCallWasCalled")
        mockMiddlewareHandler.setupCallWasCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.callingAction(.setupCall))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_startCallCallingAction_then_handlerStartCallBeingCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "startCallWasCalled")
        mockMiddlewareHandler.startCallWasCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.callingAction(.callStartRequested))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_endCallCallingAction_then_handlerEndCallBeingCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "endCallWasCalled")
        mockMiddlewareHandler.endCallWasCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.callingAction(.callEndRequested))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_requestMicrophoneOffLocalUserAction_then_handlerRequestMicMuteCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "requestMicMuteCalled")
        mockMiddlewareHandler.requestMicMuteCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.localUserAction(.microphoneOffTriggered))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_requestMicrophoneOnLocalUserAction_then_handlerRequestMicUnmuteCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "requestMicUnmuteCalled")
        mockMiddlewareHandler.requestMicUnmuteCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.localUserAction(.microphoneOnTriggered))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_cameraPermissionGranted_then_handlerOnCameraPermissionIsSet() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "cameraPermissionSetCalled")
        mockMiddlewareHandler.cameraPermissionSetCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.permissionAction(.cameraPermissionGranted))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_requestCameraPreviewOn_then_handlerRequestCameraPreviewOnCalled() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "requestCameraPreviewOnCalled")
        mockMiddlewareHandler.requestCameraPreviewOnCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.localUserAction(.cameraPreviewOnTriggered))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_requestCameraOnLocalUserAction_then_handlerRequestCameraOnCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "requestCameraOnCalled")
        mockMiddlewareHandler.requestCameraOnCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.localUserAction(.cameraOnTriggered))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_requestCameraOffLocalUserAction_then_handlerRequestCameraOffCalled() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "requestCameraOffCalled")
        mockMiddlewareHandler.requestCameraOffCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.localUserAction(.cameraOffTriggered))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_holdCallRequestAction_then_handlerHoldCall() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "requestHoldCalled")
        mockMiddlewareHandler.requestHoldCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.callingAction(.holdRequested))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_resumeCallRequestAction_then_handlerResumeCall() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let expectation = expectation(description: "requestResumeCalled")
        mockMiddlewareHandler.requestResumeCalled = { value in
            XCTAssertTrue(value)
            expectation.fulfill()
        }

        middlewareDispatch(getEmptyDispatch())(.callingAction(.resumeRequested))
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_requestCameraOn_then_nextActionDispatchCameraOnTriggered() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let action = Action.localUserAction(.cameraOnTriggered)
        let expectation = XCTestExpectation(description: "Verify is same action Type")
        let nextDispatch = getAssertSameActionDispatch(action: action, expectation: expectation)

        middlewareDispatch(nextDispatch)(action)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_requestMicOn_then_nextActionDispatchMicrophoneOnTriggered() {

        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let action = Action.localUserAction(.microphoneOnTriggered)
        let expectation = XCTestExpectation(description: "Verify is same action Type")
        let nextDispatch = getAssertSameActionDispatch(action: action, expectation: expectation)

        middlewareDispatch(nextDispatch)(action)
        wait(for: [expectation], timeout: 1)
    }

    func test_callingMiddleware_apply_when_enterForeground_then_nextActionDispatchEnterForeground() {
        let middlewareDispatch = getEmptyCallingMiddlewareFunction()
        let action = Action.lifecycleAction(.foregroundEntered)
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
        let mockMiddleware: Middleware<AppState> = .liveCallingMiddleware(callingMiddlewareHandler: mockMiddlewareHandler)
        return mockMiddleware.apply(getEmptyDispatch(), getEmptyState)
    }

    private func getAssertSameActionDispatch(action: Action, expectation: XCTestExpectation) -> ActionDispatch {
        return { nextAction in
            XCTAssertTrue(type(of: action) == type(of: nextAction))
            expectation.fulfill()
        }
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class ToastNotificationReducerTests: XCTestCase {
    func test_toastNotificationAction_reduce_when_cameraStartFailed_then_cameraStartFailed() {
        let state = ToastNotificationState()
        let action = ToastNotificationAction.showNotification(kind: .cameraStartFailed)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.status, .cameraStartFailed)
    }

    func test_toastNotificationAction_reduce_when_dismissNotification_then_nil() {
        let state = ToastNotificationState()
        let action = ToastNotificationAction.dismissNotification
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertNil(resultState.status)
    }
}

extension ToastNotificationReducerTests {
    private func makeSUT() -> Reducer<ToastNotificationState, ToastNotificationAction> {
        return .toastNotificationReducer
    }
}

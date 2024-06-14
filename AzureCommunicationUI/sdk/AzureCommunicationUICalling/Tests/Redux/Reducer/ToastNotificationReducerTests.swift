//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUICalling

class ToastNotificationReducerTests: XCTestCase {
    func test_permissionReducer_reduce_when_audioPermissionSet_shouldReturnAudioPermissionGranted() {
        let state = ToastNotificationState()
        let action = ToastNotificationAction.showNotification(kind: .cameraStartFailed)
        let sut = makeSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.status, .cameraStartFailed)
    }
}

extension ToastNotificationReducerTests {
    private func makeSUT() -> Reducer<ToastNotificationState, ToastNotificationAction> {
        return .toastNotificationReducer
    }
}

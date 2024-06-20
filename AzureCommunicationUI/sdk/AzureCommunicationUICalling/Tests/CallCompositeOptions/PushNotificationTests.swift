//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
import AzureCommunicationCalling
@testable import AzureCommunicationUICalling

class PushNotificationTests: XCTestCase {
    func test_pushnotification_init() {
        let testData: [AnyHashable: Any] = [
                    "callId": "4aaf485e-2991-4483-986f-518f60684c23",
                    "callerId ": "test",
                    "convoId": "test",
                    "cp": "test",
                    "displayName": "Inder",
                    "eventId": 107,
                    "participantId": "test",
                    "recipientId": "John",
                    "videoCall": false
                ]

        let pushNotification = PushNotification(data: testData)

        XCTAssertEqual(pushNotification.callId, "4AAF485E-2991-4483-986F-518F60684C23")
        XCTAssertEqual(pushNotification.eventType, .incomingCall)
        XCTAssertEqual(pushNotification.fromDisplayName, "Inder")
        XCTAssertEqual(pushNotification.hasIncomingVideo, false)
    }
}

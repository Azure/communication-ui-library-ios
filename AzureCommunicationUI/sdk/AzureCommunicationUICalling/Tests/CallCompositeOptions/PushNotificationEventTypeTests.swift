//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCalling
@testable import AzureCommunicationUICalling

class PushNotificationEventType: XCTestCase {
    func test_pushNotificationEventType_initialization() {
        let incomingCall = AzureCommunicationUICalling.PushNotificationEventType.incomingCall
        let incomingGroupCall = AzureCommunicationUICalling.PushNotificationEventType.incomingGroupCall
        let incomingPstnCall = AzureCommunicationUICalling.PushNotificationEventType.incomingPstnCall
        let stopRinging = AzureCommunicationUICalling.PushNotificationEventType.stopRinging

        XCTAssertEqual(incomingCall.requestString, "incomingcall")
        XCTAssertEqual(incomingGroupCall.requestString, "incominggroupcall")
        XCTAssertEqual(incomingPstnCall.requestString, "incomingpstncall")
        XCTAssertEqual(stopRinging.requestString, "stopringing")
        XCTAssertTrue(incomingCall == AzureCommunicationUICalling.PushNotificationEventType.incomingCall)
    }

    func test_pushNotificationEventType_conversion() {
        let azureEventType = AzureCommunicationCalling.PushNotificationEventType.incomingCall
        let eventType = azureEventType.toPushNotificationEventType()
        XCTAssertEqual(eventType, .incomingCall)

        let azureEventTypeGroupCall = AzureCommunicationCalling.PushNotificationEventType.incomingGroupCall
        let eventTypeGroupCall = azureEventTypeGroupCall.toPushNotificationEventType()
        XCTAssertEqual(eventTypeGroupCall, .incomingGroupCall)

        let azureEventTypePstn = AzureCommunicationCalling.PushNotificationEventType.incomingPstnCall
        let eventTypeGroupPstn = azureEventTypePstn.toPushNotificationEventType()
        XCTAssertEqual(eventTypeGroupPstn, .incomingPstnCall)

        let azureEventTypeStopRinging = AzureCommunicationCalling.PushNotificationEventType.stopRinging
        let eventTypeStopRinging = azureEventTypeStopRinging.toPushNotificationEventType()
        XCTAssertEqual(eventTypeStopRinging, .stopRinging)
    }
}

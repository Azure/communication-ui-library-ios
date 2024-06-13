//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CallConfigurationTests: XCTestCase {

    func testGroupCallInitialization() {
        let groupId = UUID()
        let locator = JoinLocator.groupCall(groupId: groupId)
        let config = CallConfiguration(locator: locator, participants: nil, callId: nil)

        XCTAssertEqual(config.groupId, groupId)
        XCTAssertNil(config.meetingLink)
        XCTAssertNil(config.meetingId)
        XCTAssertNil(config.meetingPasscode)
        XCTAssertNil(config.roomId)
        XCTAssertEqual(config.compositeCallType, .groupCall)
        XCTAssertNil(config.participants)
    }

    func testTeamsMeetingLinkInitialization() {
        let meetingLink = "https://example.com/meeting"
        let locator = JoinLocator.teamsMeeting(teamsLink: meetingLink)
        let config = CallConfiguration(locator: locator, participants: nil, callId: nil)

        XCTAssertNil(config.groupId)
        XCTAssertEqual(config.meetingLink, meetingLink)
        XCTAssertNil(config.meetingId)
        XCTAssertNil(config.meetingPasscode)
        XCTAssertNil(config.roomId)
        XCTAssertEqual(config.compositeCallType, .teamsMeeting)
        XCTAssertNil(config.participants)
    }

    func testTeamsMeetingIdInitialization() {
        let meetingId = "meeting123"
        let meetingPasscode = "pass123"
        let locator = JoinLocator.teamsMeetingId(meetingId: meetingId, meetingPasscode: meetingPasscode)
        let config = CallConfiguration(locator: locator, participants: nil, callId: nil)

        XCTAssertNil(config.groupId)
        XCTAssertNil(config.meetingLink)
        XCTAssertEqual(config.meetingId, meetingId)
        XCTAssertEqual(config.meetingPasscode, meetingPasscode)
        XCTAssertNil(config.roomId)
        XCTAssertEqual(config.compositeCallType, .teamsMeeting)
        XCTAssertNil(config.participants)
    }
    func testOneToOneIncomingInitialization() {
        let callId = "call123"
        let config = CallConfiguration(locator: nil, participants: nil, callId: callId)

        XCTAssertNil(config.groupId)
        XCTAssertNil(config.meetingLink)
        XCTAssertNil(config.meetingId)
        XCTAssertNil(config.meetingPasscode)
        XCTAssertNil(config.roomId)
        XCTAssertEqual(config.compositeCallType, .oneToOneIncoming)
        XCTAssertEqual(config.callId, callId)
        XCTAssertNil(config.participants)
    }
}

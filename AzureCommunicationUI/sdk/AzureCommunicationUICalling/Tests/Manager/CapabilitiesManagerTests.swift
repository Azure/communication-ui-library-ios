//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class CapabilitiesManagerTests: XCTestCase {
    func test_capabilitiesManager_when_groupCall_then_anyCapabilityTrue() {
        let sut = CapabilitiesManager(callType: .groupCall)
        XCTAssertEqual(true, sut.hasCapability(capabilities: Set(), capability: .addCommunicationUser))
        XCTAssertEqual(true, sut.hasCapability(capabilities: Set(), capability: .manageLobby))
        XCTAssertEqual(true, sut.hasCapability(capabilities: Set(), capability: .turnVideoOn))
    }

    func test_capabilitiesManager_when_oneToNOutgoing_then_anyCapabilityTrue() {
        let sut = CapabilitiesManager(callType: .oneToNOutgoing)
        XCTAssertEqual(true, sut.hasCapability(capabilities: Set(), capability: .addCommunicationUser))
        XCTAssertEqual(true, sut.hasCapability(capabilities: Set(), capability: .manageLobby))
        XCTAssertEqual(true, sut.hasCapability(capabilities: Set(), capability: .turnVideoOn))
    }

    func test_capabilitiesManager_when_oneToOneIncoming_then_anyCapabilityTrue() {
        let sut = CapabilitiesManager(callType: .oneToOneIncoming)
        XCTAssertEqual(true, sut.hasCapability(capabilities: Set(), capability: .addCommunicationUser))
        XCTAssertEqual(true, sut.hasCapability(capabilities: Set(), capability: .manageLobby))
        XCTAssertEqual(true, sut.hasCapability(capabilities: Set(), capability: .turnVideoOn))
    }

    func test_capabilitiesManager_when_roomsCall_then_onlePresentCapabilityTrue() {
        let sut = CapabilitiesManager(callType: .roomsCall)
        XCTAssertEqual(false, sut.hasCapability(capabilities: Set(), capability: .addCommunicationUser))
        XCTAssertEqual(false, sut.hasCapability(capabilities: Set(), capability: .manageLobby))
        XCTAssertEqual(false, sut.hasCapability(capabilities: Set(), capability: .turnVideoOn))

        let capabilities: Set<ParticipantCapabilityType> = [.unmuteMicrophone, .turnVideoOn]
        XCTAssertEqual(false, sut.hasCapability(capabilities: capabilities, capability: .addCommunicationUser))
        XCTAssertEqual(false, sut.hasCapability(capabilities: capabilities, capability: .manageLobby))

        XCTAssertEqual(true, sut.hasCapability(capabilities: capabilities, capability: .unmuteMicrophone))
        XCTAssertEqual(true, sut.hasCapability(capabilities: capabilities, capability: .turnVideoOn))
    }

    func test_capabilitiesManager_when_teamsMeeting_then_onlePresentCapabilityTrue() {
        let sut = CapabilitiesManager(callType: .teamsMeeting)
        XCTAssertEqual(false, sut.hasCapability(capabilities: Set(), capability: .addCommunicationUser))
        XCTAssertEqual(false, sut.hasCapability(capabilities: Set(), capability: .manageLobby))
        XCTAssertEqual(false, sut.hasCapability(capabilities: Set(), capability: .turnVideoOn))

        let capabilities: Set<ParticipantCapabilityType> = [.unmuteMicrophone, .turnVideoOn]
        XCTAssertEqual(false, sut.hasCapability(capabilities: capabilities, capability: .addCommunicationUser))
        XCTAssertEqual(false, sut.hasCapability(capabilities: capabilities, capability: .manageLobby))

        XCTAssertEqual(true, sut.hasCapability(capabilities: capabilities, capability: .unmuteMicrophone))
        XCTAssertEqual(true, sut.hasCapability(capabilities: capabilities, capability: .turnVideoOn))
    }
}

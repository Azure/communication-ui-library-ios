//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCalling
@testable import AzureCommunicationUICalling

class CapabilitiesManagerTests: XCTestCase {
    func test_capabilityResolutionReason_when_explicitConsentRequired_then_preservesReason() {
        let reason = AzureCommunicationCalling.CapabilityResolutionReason.explicitConsentRequired

        XCTAssertEqual("explicitConsentRequired", reason.toCapabilityResolutionReason().rawValue)
    }

    func test_participantCapabilityType_when_muteOthers_then_remainsUnsupported() {
        let capability = AzureCommunicationCalling.ParticipantCapabilityType.muteOthers

        XCTAssertEqual(.none, capability.toParticipantCapabilityType())
    }

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

        let capabilities: Set<AzureCommunicationUICalling.ParticipantCapabilityType> = [.unmuteMicrophone, .turnVideoOn]
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

        let capabilities: Set<AzureCommunicationUICalling.ParticipantCapabilityType> = [.unmuteMicrophone, .turnVideoOn]
        XCTAssertEqual(false, sut.hasCapability(capabilities: capabilities, capability: .addCommunicationUser))
        XCTAssertEqual(false, sut.hasCapability(capabilities: capabilities, capability: .manageLobby))

        XCTAssertEqual(true, sut.hasCapability(capabilities: capabilities, capability: .unmuteMicrophone))
        XCTAssertEqual(true, sut.hasCapability(capabilities: capabilities, capability: .turnVideoOn))
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

class RemoteOptionsTests: XCTestCase {
    func test_remoteOptions_init_groupCall_when_parametersAreValid_then_returnRemoteOptionsObject() {
        let sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
        let communicationTokenCredential = try? CommunicationTokenCredential(token: sampleToken)
        let displayName = "Display Name"
        let groupId = UUID()

        let remoteOptions = RemoteOptions(for: .groupCall(groupId: groupId),
                                          credential: communicationTokenCredential!,
                                          displayName: displayName)

        XCTAssertNotNil(remoteOptions)
        XCTAssertEqual(remoteOptions.displayName, displayName)
        XCTAssertNotNil(remoteOptions.locator)
        switch remoteOptions.locator {
        case let .groupCall(groupId: locatorGroupId):
            XCTAssertEqual(locatorGroupId.uuidString, groupId.uuidString)
        case let .teamsMeeting(teamsLink: locatorTeamsLink):
            XCTFail("Should not be a teams meeting with teamsLink \(locatorTeamsLink)")
        }
    }

    func test_remoteOptions_init_teamsMeeting_when_parametersAreValid_then_returnRemoteOptionsObject() {
        let sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
        let communicationTokenCredential = try? CommunicationTokenCredential(token: sampleToken)
        let displayName = "Display Name"
        let meetingLink = "asdf"

        let remoteOptions = RemoteOptions(for: .teamsMeeting(teamsLink: meetingLink),
                                          credential: communicationTokenCredential!,
                                          displayName: displayName)

        XCTAssertNotNil(remoteOptions)
        XCTAssertEqual(remoteOptions.displayName, displayName)
        XCTAssertNotNil(remoteOptions.locator)
        switch remoteOptions.locator {
        case let .groupCall(groupId: locatorGroupId):
            XCTFail("Should not be a group call with groupId \(locatorGroupId)")
        case let .teamsMeeting(teamsLink: locatorTeamsLink):
            XCTAssertEqual(locatorTeamsLink, meetingLink)
        }
    }
}

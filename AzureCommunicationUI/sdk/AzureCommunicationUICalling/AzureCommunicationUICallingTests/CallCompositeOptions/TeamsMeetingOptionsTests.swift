//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class TeamsMeetingOptionsTests: XCTestCase {
    func test_teamsMeetingOptions_init_when_parametersAreValid_then_returnTeamsMeetingOptionsObject() {
        let sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
        let communicationTokenCredential = try? CommunicationTokenCredential(token: sampleToken)
        let displayName = "Display Name"
        let meetingLink = "asdf"

        let options = TeamsMeetingOptions(credential: communicationTokenCredential!, meetingLink: meetingLink, displayName: displayName)

        XCTAssertNotNil(options)
        XCTAssertEqual(options.displayName, displayName)
        XCTAssertEqual(options.meetingLink, meetingLink)
    }
}

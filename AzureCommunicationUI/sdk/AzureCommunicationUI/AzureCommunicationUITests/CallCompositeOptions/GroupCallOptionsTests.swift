//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUI

class GroupCallOptionsTests: XCTestCase {
    func test_groupCallOptions_init_when_parametersAreValid_then_returnGroupCallOptionsObject() {
        let sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
        let communicationTokenCredential = try? CommunicationTokenCredential(token: sampleToken)
        let displayName = "Display Name"
        let groupId = UUID()

        let groupCallOptions = GroupCallOptions(credential: communicationTokenCredential!, groupId: groupId, displayName: displayName)

        XCTAssertNotNil(groupCallOptions)
        XCTAssertEqual(groupCallOptions.displayName, displayName)
        XCTAssertEqual(groupCallOptions.groupId.uuidString, groupId.uuidString)
    }
}

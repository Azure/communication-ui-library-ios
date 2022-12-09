//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation
import XCTest

@testable import AzureCommunicationUICalling

class CallCompositeTests: XCTestCase {
    func test_verify_construction() {
        let callComposite = CallComposite()

        XCTAssertNotNil(callComposite)
    }

    func test_verify_launch() throws {

        let sampleToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
        let communicationTokenCredential = try CommunicationTokenCredential(token: sampleToken)
        let callComposite = CallComposite(withOptions: CallCompositeOptions())
        callComposite.launch(
            remoteOptions: RemoteOptions(
                for: .groupCall(groupId: UUID()),
                credential: communicationTokenCredential
            ),
            localOptions: LocalOptions(
                participantViewData: ParticipantViewData(
                    avatar: nil, displayName: "Test"
                )
            )
        )
        // No throwing or crash is a test pass
    }
}

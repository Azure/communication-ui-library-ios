//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
@_spi(CallCompositeUITest) import AzureCommunicationUICalling

struct CallConfigurationMocking {
    let groupId: UUID?
    let meetingLink: String?
    let compositeCallType: CompositeCallTypeMocking
    let credential: CommunicationTokenCredential
    let displayName: String?

    init() {
        self.groupId = UUID()
        self.meetingLink = nil
        self.compositeCallType = .groupCall
        let sampleToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjMyNTAzNjgwMDAwfQ.9i7FNNHHJT8cOzo-yrAUJyBSfJ-tPPk2emcHavOEpWc"
        let communicationTokenCredential = try? CommunicationTokenCredential(token: sampleToken)
        self.credential = communicationTokenCredential!
        self.displayName = "E2E testing"
    }
}

enum CompositeCallTypeMocking {
    case groupCall
    case teamsMeeting
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

struct CallConfiguration {
    let credential: CommunicationTokenCredential
    let displayName: String?
    let groupId: UUID?
    let meetingLink: String?
    let compositeCallType: CompositeCallType
    let diagnosticConfig: DiagnosticConfig

    init(credential: CommunicationTokenCredential,
         groupId: UUID,
         displayName: String?) {
        self.credential = credential
        self.displayName = displayName
        self.groupId = groupId
        self.meetingLink = nil
        self.compositeCallType = .groupCall
        self.diagnosticConfig = DiagnosticConfig()
    }

    init(credential: CommunicationTokenCredential,
         meetingLink: String,
         displayName: String?) {
        self.credential = credential
        self.displayName = displayName
        self.groupId = nil
        self.meetingLink = meetingLink
        self.compositeCallType = .teamsMeeting
        self.diagnosticConfig = DiagnosticConfig()
    }
}

enum CompositeCallType {
    case groupCall
    case teamsMeeting
}

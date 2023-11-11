//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

struct CallConfiguration {
    let groupId: UUID?
    let meetingLink: String?
    let compositeCallType: CompositeCallType
    let credential: CommunicationTokenCredential?
    let displayName: String?
    let diagnosticConfig: DiagnosticConfig
    let callKitOptions: CallCompositeCallKitOption?
    let participants: [String]?

    init(locator: JoinLocator,
         credential: CommunicationTokenCredential,
         displayName: String?,
         callKitOptions: CallCompositeCallKitOption? = nil,
         diagnosticConfig: DiagnosticConfig) {
        switch locator {
        case let .groupCall(groupId: groupId):
            self.groupId = groupId
            self.meetingLink = nil
            self.compositeCallType = .groupCall
        case let .teamsMeeting(teamsLink: meetingLink):
            self.groupId = nil
            self.meetingLink = meetingLink
            self.compositeCallType = .teamsMeeting
        }
        self.credential = credential
        self.displayName = displayName
        self.participants = nil
        self.diagnosticConfig = diagnosticConfig
        self.callKitOptions = callKitOptions
    }

    init(startCallOptions: StartCallOptionsOneToNCall,
         credential: CommunicationTokenCredential,
         displayName: String?,
         callKitOptions: CallCompositeCallKitOption? = nil,
         diagnosticConfig: DiagnosticConfig) {
        self.participants = startCallOptions.participants
        self.compositeCallType = .oneToNCallOutgoing
        self.credential = credential
        self.displayName = displayName
        self.groupId = nil
        self.meetingLink = nil
        self.callKitOptions = callKitOptions
        self.diagnosticConfig = diagnosticConfig
    }

    init(callType: CompositeCallType,
         diagnosticConfig: DiagnosticConfig,
         displayName: String?,
         callKitOptions: CallCompositeCallKitOption) {
        self.participants = nil
        self.compositeCallType = callType
        self.credential = nil
        self.displayName = displayName
        self.groupId = nil
        self.meetingLink = nil
        self.callKitOptions = callKitOptions
        self.diagnosticConfig = diagnosticConfig
    }
}

enum CompositeCallType {
    case groupCall
    case teamsMeeting
    case oneToNCallOutgoing
    case oneToNCallIncoming
}

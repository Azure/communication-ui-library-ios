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
    let roomId: String?
    let roomRoleHint: ParticipantRole?
    let disableInternalPushForIncomingCall: Bool

    init(locator: JoinLocator,
         credential: CommunicationTokenCredential,
         displayName: String?,
         callKitOptions: CallCompositeCallKitOption? = nil,
         diagnosticConfig: DiagnosticConfig,
         roomRole: ParticipantRole?,
         disableInternalPushForIncomingCall: Bool) {
        switch locator {
        case let .groupCall(groupId: groupId):
            self.groupId = groupId
            self.meetingLink = nil
            self.roomId = nil
            self.roomRoleHint = nil
            self.compositeCallType = .groupCall
        case let .teamsMeeting(teamsLink: meetingLink):
            self.groupId = nil
            self.meetingLink = meetingLink
            self.roomId = nil
            self.roomRoleHint = nil
            self.compositeCallType = .teamsMeeting
        case let .roomCall(roomId: roomId):
            self.roomId = roomId
            self.roomRoleHint = roomRole
            self.groupId = nil
            self.meetingLink = nil
            self.compositeCallType = .roomsCall
        }
        self.credential = credential
        self.displayName = displayName
        self.participants = nil
        self.diagnosticConfig = diagnosticConfig
        self.callKitOptions = callKitOptions
        self.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
    }

    init(startCallOptions: CallCompositeStartCallOptions,
         credential: CommunicationTokenCredential,
         displayName: String?,
         callKitOptions: CallCompositeCallKitOption? = nil,
         diagnosticConfig: DiagnosticConfig,
         disableInternalPushForIncomingCall: Bool) {
        self.participants = startCallOptions.participants
        self.compositeCallType = .oneToNCallOutgoing
        self.credential = credential
        self.displayName = displayName
        self.groupId = nil
        self.meetingLink = nil
        self.callKitOptions = callKitOptions
        self.diagnosticConfig = diagnosticConfig
        self.roomId = nil
        self.roomRoleHint = nil
        self.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
    }

    init(callType: CompositeCallType,
         diagnosticConfig: DiagnosticConfig,
         displayName: String?,
         callKitOptions: CallCompositeCallKitOption,
         disableInternalPushForIncomingCall: Bool) {
        self.participants = nil
        self.compositeCallType = callType
        self.credential = nil
        self.displayName = displayName
        self.groupId = nil
        self.meetingLink = nil
        self.callKitOptions = callKitOptions
        self.diagnosticConfig = diagnosticConfig
        self.roomId = nil
        self.roomRoleHint = nil
        self.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
    }
}

enum CompositeCallType {
    case groupCall
    case teamsMeeting
    case oneToNCallOutgoing
    case oneToNCallIncoming
    case roomsCall
}

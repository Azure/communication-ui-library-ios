//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationCalling

struct CallConfiguration {
    let groupId: UUID?
    let meetingLink: String?
    let compositeCallType: CompositeCallType
    let credential: CommunicationTokenCredential
    let displayName: String?
    let diagnosticConfig: DiagnosticConfig
    let roomId: String?
    let roomRoleHint: ParticipantRole?
    let enableCallKitInSDK: Bool
    let pushNotificationInfo: PushNotificationInfo?
    let participantMri: String?
    let acceptIncomingCall: Bool?

    init(locator: JoinLocator,
         credential: CommunicationTokenCredential,
         displayName: String?,
         pushNotificationInfo: PushNotificationInfo?,
         enableCallKitInSDK: Bool,
         roomRole: ParticipantRole?) {
        switch locator {
        case let .groupCall(groupId: groupId):
            self.groupId = groupId
            self.meetingLink = nil
            self.roomId = nil
            self.roomRoleHint = nil
            self.pushNotificationInfo = nil
            self.acceptIncomingCall = false
            self.participantMri = nil
            self.compositeCallType = .groupCall
        case let .teamsMeeting(teamsLink: meetingLink):
            self.groupId = nil
            self.meetingLink = meetingLink
            self.roomId = nil
            self.roomRoleHint = nil
            self.pushNotificationInfo = nil
            self.acceptIncomingCall = false
            self.participantMri = nil
            self.compositeCallType = .teamsMeeting
        case let .roomCall(roomId: roomId):
            self.roomId = roomId
            self.roomRoleHint = roomRole
            self.groupId = nil
            self.meetingLink = nil
            self.pushNotificationInfo = nil
            self.acceptIncomingCall = false
            self.participantMri = nil
            self.compositeCallType = .roomsCall
        case .incomingCall(pushNotificationInfo: let pushNotificationInfo, acceptIncomingCall: let acceptIncomingCall):
            self.roomId = nil
            self.roomRoleHint = nil
            self.groupId = nil
            self.meetingLink = nil
            self.compositeCallType = .incomingCall
            self.pushNotificationInfo = pushNotificationInfo
            self.acceptIncomingCall = acceptIncomingCall
            self.participantMri = nil
        case .participantDial(participantMri: let participantMri):
            self.roomId = nil
            self.roomRoleHint = nil
            self.groupId = nil
            self.meetingLink = nil
            self.compositeCallType = .dialCall
            self.pushNotificationInfo = nil
            self.acceptIncomingCall = false
            self.participantMri = participantMri
        }
        self.credential = credential
        self.displayName = displayName
        self.enableCallKitInSDK = enableCallKitInSDK
        self.diagnosticConfig = DiagnosticConfig()
    }
}

enum CompositeCallType {
    case groupCall
    case teamsMeeting
    case roomsCall
    case dialCall
    case incomingCall
}

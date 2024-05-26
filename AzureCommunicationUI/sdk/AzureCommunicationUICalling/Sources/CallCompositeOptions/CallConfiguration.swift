//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

struct CallConfiguration {
    let groupId: UUID?
    let meetingLink: String?
    let callId: String?
    let compositeCallType: CompositeCallType
    let diagnosticConfig: DiagnosticConfig
    let participants: [CommunicationIdentifier]?
    /* <ROOMS_SUPPORT:7> */
    let roomId: String?
    let roomRoleHint: ParticipantRole?
    /* </ROOMS_SUPPORT> */
    init(locator: JoinLocator? /* <ROOMS_SUPPORT> */,
         roleHint: ParticipantRole? /* </ROOMS_SUPPORT> */,
         participants: [CommunicationIdentifier]?,
         callId: String?) {
        if let locator = locator {
            self.callId = nil
            switch locator {
            case let .groupCall(groupId: groupId):
                self.groupId = groupId
                self.meetingLink = nil
                self.participants = nil
                /* <ROOMS_SUPPORT> */
                self.roomId = nil
                self.roomRoleHint = nil
                /* </ROOMS_SUPPORT> */
                self.compositeCallType = .groupCall
            case let .teamsMeeting(teamsLink: meetingLink):
                self.groupId = nil
                self.participants = nil
                self.meetingLink = meetingLink
                self.compositeCallType = .teamsMeeting
            /* <ROOMS_SUPPORT> */
                self.roomId = nil
                self.roomRoleHint = nil
            case let .roomCall(roomId: roomId):
                self.roomId = roomId
                self.roomRoleHint = roleHint
                self.groupId = nil
                self.meetingLink = nil
                self.compositeCallType = .roomsCall
                self.participants = nil
            /* </ROOMS_SUPPORT> */
            }
        } else if participants != nil {
            self.participants = participants
            /* <ROOMS_SUPPORT> */
            self.roomId = nil
            self.roomRoleHint = nil
            /* </ROOMS_SUPPORT> */
            self.groupId = nil
            self.meetingLink = nil
            self.compositeCallType = .oneToNOutgoing
            self.callId = nil
        } else {
            self.participants = nil
            /* <ROOMS_SUPPORT> */
            self.roomId = nil
            self.roomRoleHint = nil
            /* </ROOMS_SUPPORT> */
            self.groupId = nil
            self.meetingLink = nil
            self.compositeCallType = .oneToOneIncoming
            self.callId = callId
        }
        self.diagnosticConfig = DiagnosticConfig()
    }
}

enum CompositeCallType {
    case groupCall
    case teamsMeeting
    case oneToNOutgoing
    case oneToOneIncoming
    /* <ROOMS_SUPPORT:3> */ case roomsCall /* </ROOMS_SUPPORT:1> */
}

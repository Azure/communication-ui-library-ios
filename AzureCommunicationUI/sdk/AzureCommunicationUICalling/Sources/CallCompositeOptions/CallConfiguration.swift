//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon

struct CallConfiguration {
    let groupId: UUID?
    let meetingLink: String?
    let meetingId: String?
    let meetingPasscode: String?
    let callId: String?
    let compositeCallType: CompositeCallType
    let diagnosticConfig: DiagnosticConfig
    let participants: [CommunicationIdentifier]?
    let roomId: String?
    init(locator: JoinLocator?,
         participants: [CommunicationIdentifier]?,
         callId: String?) {
        if let locator = locator {
            self.callId = nil
            switch locator {
            case let .groupCall(groupId: groupId):
                self.groupId = groupId
                self.meetingLink = nil
                self.participants = nil
                self.meetingId = nil
                self.meetingPasscode = nil
                self.roomId = nil
                self.compositeCallType = .groupCall
            case let .teamsMeetingId(meetingId: meetingId, meetingPasscode: meetingPasscode):
                self.groupId = nil
                self.meetingLink = nil
                self.participants = nil
                self.meetingId = meetingId
                self.meetingPasscode = meetingPasscode
                self.roomId = nil
                self.compositeCallType = .teamsMeeting
            case let .teamsMeeting(teamsLink: meetingLink):
                self.groupId = nil
                self.participants = nil
                self.meetingLink = meetingLink
                self.meetingId = nil
                self.meetingPasscode = nil
                self.compositeCallType = .teamsMeeting
                self.roomId = nil
            case let .roomCall(roomId: roomId):
                self.roomId = roomId
                self.groupId = nil
                self.meetingLink = nil
                self.meetingId = nil
                self.meetingPasscode = nil
                self.compositeCallType = .roomsCall
                self.participants = nil
            }
        } else if participants != nil {
            self.participants = participants
            self.roomId = nil
            self.meetingId = nil
            self.meetingPasscode = nil
            self.groupId = nil
            self.meetingLink = nil
            self.compositeCallType = .oneToNOutgoing
            self.callId = nil
        } else {
            self.participants = nil
            self.roomId = nil
            self.meetingId = nil
            self.meetingPasscode = nil
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
    case roomsCall
}

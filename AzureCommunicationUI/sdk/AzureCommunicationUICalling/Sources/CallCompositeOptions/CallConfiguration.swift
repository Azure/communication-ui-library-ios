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
    let credential: CommunicationTokenCredential
    let displayName: String?
    let diagnosticConfig: DiagnosticConfig
    let roomId: String?
    let roomRoleHint: ParticipantRole?

    init(locator: JoinLocator,
         credential: CommunicationTokenCredential,
         displayName: String?,
         roleHint: ParticipantRole?) {
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
            self.roomRoleHint = roleHint
            self.groupId = nil
            self.meetingLink = nil
            self.compositeCallType = .roomsCall
        }
        self.credential = credential
        self.displayName = displayName
        self.diagnosticConfig = DiagnosticConfig()
    }
}

enum CompositeCallType {
    case groupCall
    case teamsMeeting
    case roomsCall
}

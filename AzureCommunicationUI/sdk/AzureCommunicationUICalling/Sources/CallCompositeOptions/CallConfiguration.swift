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
    /* <ROOMS_SUPPORT:7> */
    let roomId: String?
    /* </ROOMS_SUPPORT> */
    init(locator: JoinLocator,
         credential: CommunicationTokenCredential,
         displayName: String?) {
        switch locator {
        case let .groupCall(groupId: groupId):
            self.groupId = groupId
            self.meetingLink = nil
            /* <ROOMS_SUPPORT> */
            self.roomId = nil
            /* </ROOMS_SUPPORT> */
            self.compositeCallType = .groupCall
        case let .teamsMeeting(teamsLink: meetingLink):
            self.groupId = nil
            self.meetingLink = meetingLink
            self.compositeCallType = .teamsMeeting
        /* <ROOMS_SUPPORT> */
            self.roomId = nil
        case let .roomCall(roomId: roomId):
            self.roomId = roomId
            self.groupId = nil
            self.meetingLink = nil
            self.compositeCallType = .roomsCall
        /* </ROOMS_SUPPORT> */
        }
        self.credential = credential
        self.displayName = displayName
        self.diagnosticConfig = DiagnosticConfig()
    }
}

enum CompositeCallType {
    case groupCall
    case teamsMeeting
    /* <ROOMS_SUPPORT:3> */ case roomsCall /* </ROOMS_SUPPORT:1> */
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationUICalling

enum MeetingType: Int {
    case groupCall
    case teamsMeeting
    case oneToNCall
    /* <ROOMS_SUPPORT:3> case roomCall </ROOMS_SUPPORT> */
}

enum ChatType: Int {
    case groupChat
    case teamsChat
}

enum ACSTokenType: Int {
    case tokenUrl
    case token
}

/* <ROOMS_SUPPORT:0>
enum RoomRoleType: Int {
    case presenter
    case attendee
}
</ROOMS_SUPPORT:0> */

enum DemoError: Error {
    case invalidToken
    case invalidGroupCallId

    func getErrorCode() -> String {
        switch self {
        case .invalidToken:
            return CallCompositeErrorCode.tokenExpired
        case .invalidGroupCallId:
            return CallCompositeErrorCode.callJoin
        }
    }
}

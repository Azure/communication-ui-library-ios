//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationUICalling

enum MeetingType: Int {
    case groupCall
    case teamsMeeting
    //    case oneToNCall
    //    case roomCall
}

enum ChatType: Int {
    case groupChat
    case teamsChat
}

enum ACSTokenType: Int {
    case tokenUrl
    case token
}

enum RoomRoleType: Int {
    case presenter
    case attendee
}

enum DemoError: Error {
    case invalidToken

    func getErrorCode() -> String {
        switch self {
        case .invalidToken:
            return CallCompositeErrorCode.tokenExpired
        }
    }
}

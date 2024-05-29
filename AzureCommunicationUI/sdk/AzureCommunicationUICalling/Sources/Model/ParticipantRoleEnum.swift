//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

enum ParticipantRoleEnum: Int {
    case uninitialized
    case attendee
    case consumer
    case presenter
    case organizer
    case coOrganizer
}

extension AzureCommunicationCalling.CallParticipantRole {
    func toParticipantRole() -> ParticipantRoleEnum {
        switch self {
        case .attendee:
            return .attendee
        case .uninitialized:
            return .uninitialized
        case .consumer:
            return .consumer
        case .presenter:
            return .presenter
        case .organizer:
            return .organizer
        case .coOrganizer:
            return .coOrganizer
        }
    }
}

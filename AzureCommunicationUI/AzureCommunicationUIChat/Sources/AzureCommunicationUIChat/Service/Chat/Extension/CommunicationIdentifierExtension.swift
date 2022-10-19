//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon
import Foundation

extension CommunicationIdentifier {
    var stringValue: String {

        switch self {
        case let id as CommunicationUserIdentifier:
            return id.identifier
        case let id as PhoneNumberIdentifier:
            return id.phoneNumber
        case let id as MicrosoftTeamsUserIdentifier:
            return id.userId
        case let id as UnknownIdentifier:
            return id.identifier
        default:
            return UUID().uuidString
        }
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

extension CommunicationIdentifier {
    var stringValue: String? {
        switch self {
        case is CommunicationUserIdentifier:
            return (self as? CommunicationUserIdentifier)?.identifier
        case is UnknownIdentifier:
            return (self as? UnknownIdentifier)?.identifier
        case is PhoneNumberIdentifier:
            return (self as? PhoneNumberIdentifier)?.phoneNumber
        case is MicrosoftTeamsUserIdentifier:
            return (self as? MicrosoftTeamsUserIdentifier)?.userId
        default:
            return nil
        }
    }

}

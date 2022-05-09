//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationUICalling

struct RemoteParticipantAvatarHelper {
    private static func getRemoteParticipantId(_ identifier: CommunicationIdentifier) -> String? {
        switch identifier {
        case is CommunicationUserIdentifier:
            return (identifier as? CommunicationUserIdentifier)?.identifier
        case is UnknownIdentifier:
            return (identifier as? UnknownIdentifier)?.identifier
        case is PhoneNumberIdentifier:
            return (identifier as? PhoneNumberIdentifier)?.phoneNumber
        case is MicrosoftTeamsUserIdentifier:
            return (identifier as? MicrosoftTeamsUserIdentifier)?.userId
        default:
            return nil
        }
    }

    static func didRemoteParticipantsJoin(to callComposite: CallComposite, identifiers: [CommunicationIdentifier]) {
        let avatars = ["cat", "fox", "koala", "monkey", "mouse", "octopus"]
        for identifier in identifiers {
            let id = getRemoteParticipantId(identifier)
            if let lastSymbol = id?.last,
               let index = Int(String(lastSymbol)),
               index < avatars.count {
                let selectedAvatar = avatars[index]
                let image = UIImage(named: selectedAvatar)
                let nameIdValue = id != nil ? " \(id?.suffix(4) ?? "")" : ""
                let personaData = PersonaData(image,
                                              renderDisplayName: selectedAvatar + nameIdValue)
                callComposite.setRemoteParticipantPersonaData(for: identifier,
                                                              personaData: personaData)
            }
        }
    }
}

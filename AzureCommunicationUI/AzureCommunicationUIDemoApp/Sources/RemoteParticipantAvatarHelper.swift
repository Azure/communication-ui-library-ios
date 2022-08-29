//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCommon
import AzureCommunicationUICalling

struct RemoteParticipantAvatarHelper {
//    private static func getRemoteParticipantId(_ identifier: CommunicationIdentifier) -> String? {
//        switch identifier {
//        case is CommunicationUserIdentifier:
//            return (identifier as? CommunicationUserIdentifier)?.identifier
//        case is UnknownIdentifier:
//            return (identifier as? UnknownIdentifier)?.identifier
//        case is PhoneNumberIdentifier:
//            return (identifier as? PhoneNumberIdentifier)?.phoneNumber
//        case is MicrosoftTeamsUserIdentifier:
//            return (identifier as? MicrosoftTeamsUserIdentifier)?.userId
//        default:
//            return nil
//        }
//    }

    static func onRemoteParticipantJoined(to callComposite: CallComposite, identifiers: [CallIdentity]) {
        let avatars = ["cat", "fox", "koala", "monkey", "mouse", "octopus"]
        for identifier in identifiers {
            let id = identifier.identifier
            let nameIdValue = id != nil ? "\(id?.suffix(4) ?? "")" : ""
            var avatarImage: UIImage?
            var selectedAvatarName = ""
            if let lastSymbol = id?.last {
                let index = Int((lastSymbol.asciiValue ?? 0 ) % 6)
                selectedAvatarName = avatars[index]
                avatarImage = UIImage(named: selectedAvatarName)
            }
            let displayName = selectedAvatarName.isEmpty ? nameIdValue : "\(selectedAvatarName) \(nameIdValue)"
            let participantViewData = ParticipantViewData(avatar: avatarImage,
                                                          displayName: displayName)
            callComposite.set(remoteParticipantViewData: participantViewData,
                              for: identifier) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("::::RemoteParticipantAvatarHelper::onRemoteParticipantJoined::failure \(error)")
                }
            }
        }
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

enum ParticipantCapabilityType: String, CaseIterable, Equatable {
    case turnVideoOn
    case unmuteMicrophone
    case shareScreen
    case removeParticipant
    case hangUpForEveryone
    case addTeamsUser
    case addCommunicationUser
    case addPhoneNumber
    case manageLobby
    case spotlightParticipant
    case removeParticipantSpotlight
    case blurBackground
    case customBackground
    case startLiveCaptions
    case raiseHand
    case none
}

extension AzureCommunicationCalling.ParticipantCapabilityType {
    func toParticipantCapabilityType() -> ParticipantCapabilityType {
        switch self {
        case .turnVideoOn:
            return .turnVideoOn
        case .unmuteMicrophone:
            return .unmuteMicrophone
        case .removeParticipant:
            return .removeParticipant
        case .manageLobby:
            return .manageLobby
        case .shareScreen:
            return .shareScreen
        case .hangUpForEveryone:
            return .hangUpForEveryone
        case .addTeamsUser:
            return .addTeamsUser
        case .addCommunicationUser:
            return .addCommunicationUser
        case .addPhoneNumber:
            return .addPhoneNumber
        case .spotlightParticipant:
            return .spotlightParticipant
        case .removeParticipantSpotlight:
            return .removeParticipantSpotlight
        case .blurBackground:
            return .blurBackground
        case .customBackground:
            return .customBackground
        case .startLiveCaptions:
            return .startLiveCaptions
        case .raiseHand:
            return .raiseHand
        @unknown default:
            return .none
        }
    }
}

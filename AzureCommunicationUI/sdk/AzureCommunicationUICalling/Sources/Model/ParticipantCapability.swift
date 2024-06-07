//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

internal class ParticipantCapability: Equatable {
    static func == (lhs: ParticipantCapability, rhs: ParticipantCapability) -> Bool {
        if lhs.allowed == rhs.allowed &&
           lhs.capabilityResolutionReason == rhs.capabilityResolutionReason &&
           lhs.participantCapabilityType == rhs.participantCapabilityType {
            return true
        } else {
            return false
        }
    }

internal class ParticipantCapability {
    private let participantCapabilityType: ParticipantCapabilityType
    private let isAllowed: Bool
    private let capabilityResolutionReason: CapabilityResolutionReason

    init(
        participantCapabilityType: ParticipantCapabilityType,
        isAllowed: Bool,
        capabilityResolutionReason: CapabilityResolutionReason) {
        self.participantCapabilityType = participantCapabilityType
        self.isAllowed = isAllowed
        self.capabilityResolutionReason = capabilityResolutionReason
    }

    var type: ParticipantCapabilityType {
        return self.participantCapabilityType
    }

    var allowed: Bool {
        return self.isAllowed
    }

    var reason: CapabilityResolutionReason {
        return self.capabilityResolutionReason
    }
}

extension AzureCommunicationCalling.ParticipantCapability {
    func toParticipantCapability() -> ParticipantCapability {
        let isCapabilitySupportedByCallingUi = self.type.toParticipantCapabilityType() != .none

        if isCapabilitySupportedByCallingUi {
            return ParticipantCapability(participantCapabilityType: self.type.toParticipantCapabilityType(),
                                         isAllowed: self.isAllowed,
                                         capabilityResolutionReason: self.reason.toCapabilityResolutionReason())
        }
        return ParticipantCapability(
            participantCapabilityType: .none,
            isAllowed: false,
            capabilityResolutionReason: .notInitialized)
    }
}

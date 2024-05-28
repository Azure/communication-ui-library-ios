//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

struct CapabilitiesChangedEvent {
    let changedCapabilities: [ParticipantCapability]
    let capabilitiesChangedReason: CapabilitiesChangedReason
}

extension AzureCommunicationCalling.CapabilitiesChangedEventArgs {
    func toCapabilitiesChangedEvent() -> CapabilitiesChangedEvent {
        return CapabilitiesChangedEvent(changedCapabilities: self.changedCapabilities.compactMap { $0.toParticipantCapability() },
                                        capabilitiesChangedReason: self.reason.toCapabilitiesChangedReason())
    }
}

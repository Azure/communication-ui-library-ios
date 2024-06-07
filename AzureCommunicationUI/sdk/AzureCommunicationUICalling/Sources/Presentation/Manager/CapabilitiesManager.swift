//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

internal class CapabilitiesManager {
    private var callType: CompositeCallType

    init(callType: CompositeCallType) {
        self.callType = callType
    }

    func hasCapability(capabilities: Set<ParticipantCapabilityType>,
                       capability: ParticipantCapabilityType) -> Bool {
        switch callType {
        case .groupCall:
            return true
        case .teamsMeeting:
            return true
        case .roomsCall:
            return capabilities.contains(capability)
        }
    }
}

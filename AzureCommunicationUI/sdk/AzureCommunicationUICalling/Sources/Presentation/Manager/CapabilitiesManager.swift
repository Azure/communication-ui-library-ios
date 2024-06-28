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
        case .groupCall, .oneToNOutgoing, .oneToOneIncoming:
            return true
        case .teamsMeeting, .roomsCall:
            return capabilities.contains(capability)
        }
    }
}

extension AppState {
    func hasCapability(capability: ParticipantCapability) -> Bool {
        // TADO:
        return true
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

enum CapabilitiesChangedReason: String, CaseIterable, Equatable {
    case roleChanged
    case userPolicyChanged
    case meetingDetailsChanged
}

extension AzureCommunicationCalling.CapabilitiesChangedReason {
    func toCapabilitiesChangedReason() -> CapabilitiesChangedReason {
        switch self {
        case .roleChanged:
            return .roleChanged
        case .userPolicyChanged:
            return .userPolicyChanged
        case .meetingDetailsChanged:
            return .meetingDetailsChanged
        }
    }
}

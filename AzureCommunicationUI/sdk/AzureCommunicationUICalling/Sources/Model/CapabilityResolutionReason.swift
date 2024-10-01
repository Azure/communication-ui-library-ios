//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

enum CapabilityResolutionReason: String, CaseIterable, Equatable {
    case capable
    case callTypeRestricted
    case userPolicyRestricted
    case roleRestricted
    case meetingRestricted
    case featureNotSupported
    case notInitialized
    case notCapable
}

extension AzureCommunicationCalling.CapabilityResolutionReason {
    func toCapabilityResolutionReason() -> CapabilityResolutionReason {
        switch self {
        case .capable:
            return .capable
        case .callTypeRestricted:
            return .callTypeRestricted
        case .userPolicyRestricted:
            return .userPolicyRestricted
        case .meetingRestricted:
            return .meetingRestricted
        case .featureNotSupported:
            return .featureNotSupported
        case .notInitialized:
            return .notInitialized
        case .notCapable:
            return .notCapable
        case .roleRestricted:
            return .roleRestricted
        @unknown default:
            fatalError("Fatal Error")
        }
    }
}

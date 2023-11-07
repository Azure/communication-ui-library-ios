//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

extension AzureCommunicationCalling.DiagnosticQuality {
    func toCallCompositeDiagnosticQuality() -> CallDiagnosticQuality {
        switch self {
        case .unknown:
            return .unknown
        case .good:
            return .good
        case .poor:
            return .poor
        case .bad:
            return .bad
        @unknown default:
            return .unknown
        }
    }
}

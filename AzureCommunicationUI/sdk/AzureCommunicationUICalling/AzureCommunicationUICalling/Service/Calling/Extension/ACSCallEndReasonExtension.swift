//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

extension CallEndReason {
    func toCompositeInternalError(_ wasCallConnected: Bool) -> CallCompositeInternalError? {
        let callEndErrorCode = self.code
        let callEndErrorSubCode = self.subcode

        var internalError: CallCompositeInternalError?
        switch callEndErrorCode {
        case 0 :
            if (callEndErrorSubCode == 5300 || callEndErrorSubCode == 5000),
               wasCallConnected {
                internalError = CallCompositeInternalError.callEvicted
            } else if callEndErrorSubCode == 5854 {
                internalError = CallCompositeInternalError.callDenied
            }
        case 401:
            internalError = CallCompositeInternalError.callTokenFailed
        case 487:
            // Call cancelled by user as a happy path
            break
        default:
            // For all other errorCodes:
            // https://docs.microsoft.com/en-us/azure/communication-services/concepts/troubleshooting-info
            internalError = wasCallConnected ? CallCompositeInternalError.callEndFailed
            : CallCompositeInternalError.callJoinFailed
        }

        return internalError
    }
}

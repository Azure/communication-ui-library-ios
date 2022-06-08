//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

extension CallEndReason {
    func toCompositeErrorCodeString(_ wasCallConnected: Bool) -> CallCompositeInternalError? {
        let callEndErrorCode = self.code
        let callEndErrorSubCode = self.subcode

        var compositeErrorCodeString: CallCompositeInternalError?
        switch callEndErrorCode {
        case 0 :
            if (callEndErrorSubCode == 5300 || callEndErrorSubCode == 5000),
               wasCallConnected {
                compositeErrorCodeString = CallCompositeInternalError.callEvicted
            } else if callEndErrorSubCode == 5854 {
                compositeErrorCodeString = CallCompositeInternalError.callDenied
            }
        case 401:
            compositeErrorCodeString = CallCompositeInternalError.callTokenFailed
        case 487:
            // Call cancelled by user as a happy path
            break
        default:
            // For all other errorCodes:
            // https://docs.microsoft.com/en-us/azure/communication-services/concepts/troubleshooting-info
            compositeErrorCodeString = wasCallConnected ? CallCompositeInternalError.callEndFailed
            : CallCompositeInternalError.callJoinFailed
        }

        return compositeErrorCodeString
    }
}

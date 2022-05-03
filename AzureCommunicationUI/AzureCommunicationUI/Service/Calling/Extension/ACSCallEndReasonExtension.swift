//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

extension CallEndReason {
    func toCompositeErrorCodeString(_ wasCallConnected: Bool) -> String {
        let callEndErrorCode = self.code
        let callEndErrorSubCode = self.subcode

        var compositeErrorCodeString = ""
        switch callEndErrorCode {
        case 0 :
            if (callEndErrorSubCode == 5300 || callEndErrorSubCode == 5000),
               wasCallConnected {
                compositeErrorCodeString = CallCompositeErrorCode.callEvicted
            }
        case 401:
            compositeErrorCodeString = CallCompositeErrorCode.tokenExpired
        case 487:
            // Call cancelled by user as a happy path
            break
        default:
            // For all other errorCodes:
            // https://docs.microsoft.com/en-us/azure/communication-services/concepts/troubleshooting-info
            compositeErrorCodeString = wasCallConnected ? CallCompositeErrorCode.callEnd
            : CallCompositeErrorCode.callJoin
        }

        return compositeErrorCodeString
    }
}

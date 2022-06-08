//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum CallCompositeInternalError: String, LocalizedError, Equatable {
    case callTokenFailed = "callTokenFailed"
    case callJoinFailed = "callJoinFailed"
    case callEndFailed = "callEndFailed"
    case callHoldFailed = "callHoldFailed"
    case callResumeFailed = "callResumeFailed"
    case callEvicted = "callEvicted"
    case callDenied = "callDenied"
    case cameraSwitchFailed = "cameraSwitchFailed"

    case invalidLocalVideoStream = "InvalidLocalVideoStream"

    var localizedDescription: String { return NSLocalizedString(self.rawValue, comment: "") }
}

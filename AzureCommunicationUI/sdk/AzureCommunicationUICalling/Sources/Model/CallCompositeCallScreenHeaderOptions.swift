//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

public class CallCompositeCallScreenHeaderOptions {
    public var callCompositeCallDurationCustomTimer: CallCompositeCallDurationCustomTimer?
    public var customHeaderMessage: String?
    public init(customTimer: CallCompositeCallDurationCustomTimer? = nil,
                customHeaderMessage: String? = nil) {
        self.callCompositeCallDurationCustomTimer = customTimer
        self.customHeaderMessage = customHeaderMessage
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

public class CallScreenHeaderOptions {
    public var callDurationTimer: CallDurationTimer?
    public var title: String?
    public init(customTimer: CallDurationTimer? = nil,
                customHeaderMessage: String? = nil) {
        self.callDurationTimer = customTimer
        self.title = customHeaderMessage
    }
}

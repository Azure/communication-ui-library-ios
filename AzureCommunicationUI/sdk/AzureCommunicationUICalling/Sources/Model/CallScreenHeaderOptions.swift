//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

public class CallScreenHeaderOptions {
    public var callDurationTimer: CallDurationTimer?
    public var title: String?
    public init(callDurationTimer: CallDurationTimer? = nil,
                title: String? = nil) {
        self.callDurationTimer = callDurationTimer
        self.title = title
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public class CallDurationTimer {
    var callTimerAPI: CallTimerAPI?
    public var elapsedDuration: TimeInterval?
    public init(elapsedDuration: TimeInterval? = 0) {
        self.elapsedDuration = elapsedDuration
    }
    public func start() {
        guard let callTimerAPI = callTimerAPI else {
            return
        }
        callTimerAPI.onStart()
    }
    public func stop() {
        guard let callTimerAPI = callTimerAPI else {
            return
        }
        callTimerAPI.onStop()
    }
    public func reset() {
        guard let callTimerAPI = callTimerAPI else {
            return
        }
        callTimerAPI.onReset()
    }
}

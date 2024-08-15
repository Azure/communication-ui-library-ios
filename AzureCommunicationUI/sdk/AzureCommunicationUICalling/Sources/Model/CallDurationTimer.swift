//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

public class CallDurationTimer {
    var callTimerAPI: CallDurationManager?
    public var elapsedDuration: Int64?
    public init(elapsedDuration: Int64? = 0) {
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

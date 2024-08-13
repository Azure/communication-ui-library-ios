//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

public class CallCompositeCallDurationCustomTimer {
    var callTimerAPI: CallTimerAPI?
    public init() {
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
    public func onReset() {
        guard let callTimerAPI = callTimerAPI else {
            return
        }
        callTimerAPI.onReset()
    }
}

/* <TIMER_TITLE_FEATURE>
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Call Timer to control the timer in CallComposite
public class CallDurationTimer {
    var callTimerAPI: CallTimerAPI?
    /// Time that has already been spent after the composite has started in second
    public var elapsedDuration: TimeInterval?
    /// Creates an instance of CallDurationTimer with related options.
    /// - Parameter elapsedDuration: TimeInterval in second for specifying the
    ///  amount of time that has already been spent in call.
    public init(elapsedDuration: TimeInterval? = nil) {
        self.elapsedDuration = elapsedDuration
    }
    /// Starts the timer in the call.
    public func start() {
        guard let callTimerAPI = callTimerAPI else {
            return
        }
        callTimerAPI.onStart()
    }
    /// Stops the timer in the call
    public func stop() {
        guard let callTimerAPI = callTimerAPI else {
            return
        }
        callTimerAPI.onStop()
    }
    /// Resets the timer to initial default value of 00:00 
    public func reset() {
        guard let callTimerAPI = callTimerAPI else {
            return
        }
        callTimerAPI.onReset()
    }
}
</TIMER_TITLE_FEATURE> */

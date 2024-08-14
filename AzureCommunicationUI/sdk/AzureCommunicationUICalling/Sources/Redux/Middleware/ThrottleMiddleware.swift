//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

extension Middleware {
    // Throttles a particular action.
    //
    // Can be thought of "button smashing protection"
    //
    // I.e. if an action is dispatch 10 times in 0.4 seconds, only the first will pass through.
    // Meant for user-action's that could conflict with animations.
    //
    // The KeyGenerator is used to "Key" actions->Strings. These s
    static func throttleMiddleware(timeoutS: CGFloat = 0.4,
                                   actionKeyGenerator: @escaping (Action) -> String?) -> Middleware<State, Action> {
        let throttler = Throttler(timeoutS: timeoutS, actionKeyGenerator: actionKeyGenerator)

        return .init(
            apply: { _, _ in
                return { next in
                    return { action in
                        // Delegate to the Throttler to check if the action should be processed
                        if throttler.shouldProcess(action: action) {
                            return next(action)
                        }
                    }
                }
            }
        )
    }
}

internal class Throttler<Action> {
    private let timeoutSeconds: CGFloat
    private var lastActionTime: [String: Date] = [:]
    private let actionKeyGenerator: (Action) -> String?

    init(timeoutS: CGFloat = 0.4, actionKeyGenerator: @escaping (Action) -> String?) {
        self.timeoutSeconds = timeoutS
        self.actionKeyGenerator = actionKeyGenerator
    }

    func shouldProcess(action: Action) -> Bool {
        guard let actionID: String = actionKeyGenerator(action) else {
            return true
        }

        let currentTime = Date()
        if let lastTime = lastActionTime[actionID],
           currentTime.timeIntervalSince(lastTime) < TimeInterval(timeoutSeconds) {
            // Drop the action if it's within the throttle timeout and is the same as the last action
            return false
        }
        // Update the last action time and allow the action to pass through
        lastActionTime[actionID] = currentTime
        return true
    }
}

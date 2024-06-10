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
    static func throttleMiddleware(actions: [Action], timeoutS: CGFloat = 0.4) -> Middleware<AppState, Action> {
        var lastActionTime: [String: Date] = [:]

        func actionIdentifier(for action: Action) -> String {
            let mirror = Mirror(reflecting: action)
            if let caseName = mirror.children.first?.label {
                return "\(mirror.subjectType).\(caseName)"
            } else {
                return "\(mirror.subjectType)"
            }
        }

        return .init(
            apply: { _, _ in
                return { next in
                    return { action in
                        let currentTime = Date()
                        let actionID = actionIdentifier(for: action)

                        if let lastTime = lastActionTime[actionID],
                           currentTime.timeIntervalSince(lastTime) < TimeInterval(timeoutS) {
                            // Drop the action if it's within the throttle timeout
                            return
                        }
                        // Update the last action time and dispatch the action
                        lastActionTime[actionID] = currentTime
                        return next(action)
                    }
                }
            })
    }
}

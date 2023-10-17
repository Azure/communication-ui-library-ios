//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Intents

class IntentHandler: INExtension, INStartCallIntentHandling {
    public func handle(intent: INStartCallIntent, completion: @escaping (INStartCallIntentResponse) -> Void) {

          let response: INStartCallIntentResponse
          defer {
              completion(response)
          }

          // Ensure there is a person handle
          guard intent.contacts?.first?.personHandle != nil else {
              response = INStartCallIntentResponse(code: .failure, userActivity: nil)
              return
          }

          let userActivity = NSUserActivity(activityType: String(describing: INStartCallIntent.self))

          response = INStartCallIntentResponse(code: .continueInApp, userActivity: userActivity)
    }
}

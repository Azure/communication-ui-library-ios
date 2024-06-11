//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Intents

extension NSUserActivity: StartCallConvertible {

    private struct Constants {
        static let ActivityType = String(describing: INStartCallIntent.self)
    }

    var startCallHandle: String? {
        guard activityType == Constants.ActivityType else {
            return nil
        }

        guard
          let interaction = interaction,
          let startAudioCallIntent = interaction.intent as? INStartCallIntent,
          let contact = startAudioCallIntent.contacts?.first
        else {
            return nil
        }

        return contact.personHandle?.value
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension LocalUserState.AudioDeviceSelectionStatus {
    func icon(fallbackIcon: CompositeIcon) -> CompositeIcon {
       switch self {
       case .receiverSelected:
          return .speakerRegular
       case .speakerSelected:
          return .speakerFilled
       default:
          return fallbackIcon
       }
    }

    func label(fallBackLabel: String) -> String {
       switch self {
       case .receiverSelected:
          return AudioDeviceType.receiver.name
       case .speakerSelected:
          return AudioDeviceType.speaker.name
       default:
          return fallBackLabel
       }
    }
}

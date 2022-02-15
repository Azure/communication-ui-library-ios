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

    func label(fallbackLabel: String) -> String {
       switch self {
       case .receiverSelected:
          return AudioDeviceType.receiver.name
       case .speakerSelected:
          return AudioDeviceType.speaker.name
       default:
          return fallbackLabel
       }
    }
}

extension LocalUserState.CameraDeviceSelectionStatus {
    func label(fallbackLabel: String) -> String {
       switch self {
       case .front:
           return "Switch to back camera"
       case .back:
           return "Switch to front camera"
       default:
          return fallbackLabel
       }
    }
}

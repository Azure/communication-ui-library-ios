//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension LocalUserState.AudioDeviceSelectionStatus {
    var icon: CompositeIcon? {
       switch self {
       case .receiverSelected:
          return .speakerRegular
       case .speakerSelected:
          return .speakerFilled
       default:
           return nil
       }
    }

    var label: String {
       switch self {
       case .receiverSelected:
           return AudioDeviceType.receiver.name.rawValue
       case .speakerSelected:
           return AudioDeviceType.speaker.name.rawValue
       default:
          return ""
       }
    }
}

extension LocalUserState.CameraDeviceSelectionStatus {
    var label: String {
       switch self {
       case .front:
           return "Switch to back camera"
       case .back:
           return "Switch to front camera"
       default:
          return ""
       }
    }
}

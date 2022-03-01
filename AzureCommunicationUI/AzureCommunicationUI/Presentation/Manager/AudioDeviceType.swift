//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AVFoundation

enum AudioDeviceType: String, CaseIterable {
    case bluetooth = "Bluetooth"
    case headphones = "Headphones"
    case receiver = "iOS"
    case speaker = "Speaker"

    var name: String {
        switch self {
        case .bluetooth:
            if let output = AVAudioSession.sharedInstance().currentRoute.outputs.first,
               [.bluetoothA2DP, .bluetoothLE, .bluetoothHFP].contains(output.portType) {
                return output.portName
            }
            return self.rawValue
        case .receiver:
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                return "iPhone"
            case .pad:
                return "iPad"
            default:
                return self.rawValue
            }
        default:
            return self.rawValue
        }
    }
}

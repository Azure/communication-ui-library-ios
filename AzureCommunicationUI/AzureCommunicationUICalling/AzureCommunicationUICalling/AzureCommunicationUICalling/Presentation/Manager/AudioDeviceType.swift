//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AVFoundation

let bluetoothAudioPorts: Set<AVAudioSession.Port> = [.bluetoothA2DP, .bluetoothLE, .bluetoothHFP]
let headphonesAudioPorts: Set<AVAudioSession.Port> = [.headphones, .headsetMic]

enum AudioDeviceType: String {
    case bluetooth = "Bluetooth"
    case headphones = "Headphones"
    case receiver = "iOS"
    case speaker = "Speaker"

    var name: String {
        switch self {
        case .bluetooth:
            if let output = AVAudioSession.sharedInstance().currentRoute.outputs.first,
               bluetoothAudioPorts.contains(output.portType),
               !output.portName.isEmpty {
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

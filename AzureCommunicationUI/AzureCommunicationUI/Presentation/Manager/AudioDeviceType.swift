//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AVFoundation

let bluetoothAudioPorts: Set<AVAudioSession.Port> = [.bluetoothA2DP, .bluetoothLE, .bluetoothHFP]
let headphonesAudioPorts: Set<AVAudioSession.Port> = [.headphones, .headsetMic]

enum AudioDeviceType {
    case bluetooth
    case headphones
    case receiver
    case speaker

    var name: LocalizationKey {
        switch self {
        case .bluetooth:
            return .bluetooth
        case .headphones:
            return .headphones
        case .receiver:
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                return .iPhone
            case .pad:
                return .iPad
            default:
                return .iOS
            }
        case .speaker:
            return .speaker
        }
    }

    func getBluetoothName() -> String? {
        if let output = AVAudioSession.sharedInstance().currentRoute.outputs.first,
           bluetoothAudioPorts.contains(output.portType),
           !output.portName.isEmpty {
            return output.portName
        } else {
            return nil
        }
    }
}

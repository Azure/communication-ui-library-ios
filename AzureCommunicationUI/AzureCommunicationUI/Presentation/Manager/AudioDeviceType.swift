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

    func getName(_ localizationProvider: LocalizationProvider) -> String {
        switch self {
        case .bluetooth:
            if let output = AVAudioSession.sharedInstance().currentRoute.outputs.first,
               bluetoothAudioPorts.contains(output.portType),
               !output.portName.isEmpty {
                return output.portName
            }
            return localizationProvider.getLocalizedString(.bluetooth)
        case .headphones:
            return localizationProvider.getLocalizedString(.headphones)
        case .receiver:
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                return localizationProvider.getLocalizedString(.iPhone)
            case .pad:
                return localizationProvider.getLocalizedString(.iPad)
            default:
                return localizationProvider.getLocalizedString(.iOS)
            }
        case .speaker:
            return localizationProvider.getLocalizedString(.speaker)
        }
    }
}

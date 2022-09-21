//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension LocalUserState.AudioDeviceSelectionStatus {
    var icon: CompositeIcon? {
       switch self {
       case .bluetoothSelected:
           return .speakerBluetooth
       case .headphonesSelected:
           return .speakerRegular
       case .receiverSelected:
           return .speakerRegular
       case .speakerSelected:
           return .speakerFilled
       default:
           return nil
       }
    }

    func getLabel(localizationProvider: LocalizationProviderProtocol) -> String {
       switch self {
       case .bluetoothSelected:
           return localizationProvider.getLocalizedString(AudioDeviceType.bluetooth.name)
       case .headphonesSelected:
           return localizationProvider.getLocalizedString(AudioDeviceType.headphones.name)
       case .receiverSelected:
           return localizationProvider.getLocalizedString(AudioDeviceType.receiver.name)
       case .speakerSelected:
           return localizationProvider.getLocalizedString(AudioDeviceType.speaker.name)
       default:
          return ""
       }
    }
}

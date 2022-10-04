//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol ButtonState: Equatable {
    var iconName: CompositeIcon { get }
    var localizationKey: LocalizationKey { get }
}

enum CameraButtonState: ButtonState {
    case videoOn
    case videoOff

    var iconName: CompositeIcon {
        switch self {
        case .videoOn:
            return .videoOn
        case .videoOff:
            return .videoOff
        }
    }

    var localizationKey: LocalizationKey {
        switch self {
        case .videoOn:
            return .videoOn
        case .videoOff:
            return .videoOff
        }
    }

}

enum MicButtonState: ButtonState {
    case micOn
    case micOff

    var iconName: CompositeIcon {
        switch self {
        case .micOn:
            return .micOn
        case .micOff:
            return .micOff
        }
    }

    var localizationKey: LocalizationKey {
        switch self {
        case .micOn:
            return .micOn
        case .micOff:
            return .micOff
        }
    }
}

enum AudioButtonState: ButtonState {
    case speaker
    case receiver
    case bluetooth
    case headphones

    var iconName: CompositeIcon {
        switch self {
        case .bluetooth:
            return .speakerBluetooth
        case .headphones:
            return .speakerRegular
        case .receiver:
            return .speakerRegular
        case .speaker:
            return .speakerFilled
        }
    }

    var localizationKey: LocalizationKey {
        switch self {
        case .bluetooth:
            return AudioDeviceType.bluetooth.name
        case .headphones:
            return AudioDeviceType.headphones.name
        case .receiver:
            return AudioDeviceType.receiver.name
        case .speaker:
            return AudioDeviceType.speaker.name
        }
    }

    static func getButtonState(from audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus) -> AudioButtonState {
        switch audioDeviceStatus {
        case .speakerSelected,
                .speakerRequested:
            return .speaker
        case .receiverSelected,
                .receiverRequested:
            return .receiver
        case .bluetoothSelected,
                .bluetoothRequested:
            return .bluetooth
        case .headphonesSelected,
                .headphonesRequested:
            return .headphones
        case .error:
            return .speaker
        }
    }
}

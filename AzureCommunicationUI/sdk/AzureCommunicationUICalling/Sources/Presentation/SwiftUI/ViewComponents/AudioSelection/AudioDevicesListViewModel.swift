//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation

internal class AudioDevicesListViewModel: ObservableObject {
    @Published var audioDevicesList: [DrawerSelectableItemViewModel] = []
    @Published var isDisplayed = false

    private var audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus
    private var previousConnectedDevice: AudioDeviceType?
    private let dispatch: ActionDispatch
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         dispatchAction: @escaping ActionDispatch,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol) {
        self.dispatch = dispatchAction
        self.audioDeviceStatus = localUserState.audioState.device
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
    }

    func update(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus,
                navigationState: NavigationState,
                visibilityState: VisibilityState) {
        if audioDeviceStatus != self.audioDeviceStatus || audioDevicesList.isEmpty,
           LocalUserState.AudioDeviceSelectionStatus.isSelected(for: audioDeviceStatus) {
            self.audioDeviceStatus = audioDeviceStatus
            self.audioDevicesList = getAvailableAudioDevices(audioDeviceStatus: audioDeviceStatus)
        }
        isDisplayed = visibilityState.currentStatus == .visible && navigationState.audioSelectionVisible
    }

    private func getAvailableAudioDevices(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus)
    -> [DrawerSelectableItemViewModel] {
        let systemDefaultAudio: AudioDeviceType
        switch audioDeviceStatus {
        case .bluetoothSelected:
            systemDefaultAudio = .bluetooth
        case .headphonesSelected:
            systemDefaultAudio = .headphones
        case .receiverSelected:
            systemDefaultAudio = .receiver
        default:
            if let availableInputs = AVAudioSession.sharedInstance().availableInputs {
                let availableInputPorts = Set(availableInputs.map({ $0.portType }))
                let isBluetoothConnected = !availableInputPorts.isDisjoint(with: bluetoothAudioPorts)
                let isHeadphonesConnected = !availableInputPorts.isDisjoint(with: headphonesAudioPorts)

                if isBluetoothConnected,
                   isHeadphonesConnected,
                   let previousConnectedDevice = previousConnectedDevice {
                    systemDefaultAudio = previousConnectedDevice
                } else if isBluetoothConnected {
                    systemDefaultAudio = .bluetooth
                } else if isHeadphonesConnected {
                    systemDefaultAudio = .headphones
                } else {
                    systemDefaultAudio = .receiver
                }
            } else {
                systemDefaultAudio = .receiver
            }
        }
        previousConnectedDevice = systemDefaultAudio

        var audioDeviceOptions = [DrawerSelectableItemViewModel]()
        audioDeviceOptions.append(getAudioDeviceOption(for: systemDefaultAudio))
        audioDeviceOptions.append(getAudioDeviceOption(for: .speaker))
        return audioDeviceOptions
    }

    private func getAudioDeviceOption(for audioDeviceType: AudioDeviceType) -> DrawerSelectableItemViewModel {
        let isSelected = isAudioDeviceSelected(audioDeviceType, selectedDevice: audioDeviceStatus)
        let action = LocalUserAction.audioDeviceChangeRequested(device: audioDeviceType)
        let audioDeviceOption = DrawerSelectableItemViewModel(
            icon: getAudioDeviceIcon(audioDeviceType),
            title: getAudioDeviceTitle(audioDeviceType),
            accessibilityIdentifier: "",
            accessibilityLabel: isSelected ?
            localizationProvider.getLocalizedString(.selected, getAudioDeviceTitle(audioDeviceType)) :
                getAudioDeviceTitle(audioDeviceType),
            isSelected: isSelected,
            action: { [weak self] in self?.dispatch(.localUserAction(action)) })
        return audioDeviceOption
    }

    private func getAudioDeviceTitle(_ audioDeviceType: AudioDeviceType) -> String {
        switch audioDeviceType {
        case .bluetooth:
            return audioDeviceType.getBluetoothName() ?? localizationProvider
                .getLocalizedString(audioDeviceType.name)
        default:
            return localizationProvider.getLocalizedString(audioDeviceType.name)
        }
    }

    private func getAudioDeviceIcon(_ audioDeviceType: AudioDeviceType) -> CompositeIcon {
        switch audioDeviceType {
        case .bluetooth:
            return .speakerBluetooth
        case .speaker:
            return .speakerFilled
        default:
            return .speakerRegular
        }
    }

    private func isAudioDeviceSelected(_ audioDeviceType: AudioDeviceType,
                                       selectedDevice: LocalUserState.AudioDeviceSelectionStatus) -> Bool {
        switch selectedDevice {
        case .bluetoothSelected where audioDeviceType == .bluetooth,
             .headphonesSelected where audioDeviceType == .headphones,
             .receiverSelected where audioDeviceType == .receiver,
             .speakerSelected where audioDeviceType == .speaker:
            return true
        default:
            return false
        }
    }
}

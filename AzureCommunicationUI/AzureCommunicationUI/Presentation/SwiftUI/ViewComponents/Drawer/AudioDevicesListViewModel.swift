//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class AudioDevicesListViewModel: ObservableObject {
    @Published var audioDevicesList: [AudioDevicesListCellViewModel] = []

    private var audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus
    private let dispatch: ActionDispatch

    init(dispatchAction: @escaping ActionDispatch, localUserState: LocalUserState) {
        self.dispatch = dispatchAction
        self.audioDeviceStatus = localUserState.audioState.device
    }

    func update(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus) {
        if audioDeviceStatus != self.audioDeviceStatus || audioDevicesList.isEmpty,
           [.bluetoothSelected, .headphonesSelected, .receiverSelected, .speakerSelected].contains(audioDeviceStatus) {
            self.audioDeviceStatus = audioDeviceStatus
            self.audioDevicesList = getAvailableAudioDevices(audioDeviceStatus: audioDeviceStatus)
        }
    }

    private func getAvailableAudioDevices(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus)
    -> [AudioDevicesListCellViewModel] {
        var audioDeviceOptions = [AudioDevicesListCellViewModel]()

        let audioDeviceType: AudioDeviceType
        switch audioDeviceStatus {
        case .bluetoothSelected:
            audioDeviceType = .bluetooth
        case .headphonesSelected:
            audioDeviceType = .headphones
        default:
            audioDeviceType = .receiver
        }
        audioDeviceOptions.append(getAudioDeviceOption(for: audioDeviceType))
        audioDeviceOptions.append(getAudioDeviceOption(for: .speaker))

        return audioDeviceOptions
    }

    private func getAudioDeviceOption(for audioDeviceType: AudioDeviceType) -> AudioDevicesListCellViewModel {
        let isSelected = isAudioDeviceSelected(audioDeviceType, selectedDevice: audioDeviceStatus)
        let action = LocalUserAction.AudioDeviceChangeRequested(device: audioDeviceType)
        let audioDeviceOption = AudioDevicesListCellViewModel(
            icon: getAudioDeviceIcon(audioDeviceType),
            title: audioDeviceType.name,
            isSelected: isSelected,
            onSelected: { [weak self] in self?.dispatch(action) })
        return audioDeviceOption
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

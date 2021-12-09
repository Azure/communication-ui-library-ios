//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class AudioDeviceListViewModel: ObservableObject {
    @Published var audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus
    var audioDeviceList: [PopupMenuViewModel] = []

    private let dispatch: ActionDispatch

    init(dispatchAction: @escaping ActionDispatch, localUserState: LocalUserState) {
        self.dispatch = dispatchAction
        self.audioDeviceStatus = localUserState.audioState.device
    }

    func update(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus) {
        if audioDeviceStatus != self.audioDeviceStatus || audioDeviceList.isEmpty,
           [.receiverSelected, .speakerSelected].contains(audioDeviceStatus) {
            self.audioDeviceStatus = audioDeviceStatus
            audioDeviceList = getAvailableAudioDevices(audioDeviceStatus: audioDeviceStatus)
        }
    }

    private func getAvailableAudioDevices(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus)
    -> [PopupMenuViewModel] {
        var audioDeviceOptions = [PopupMenuViewModel]()

        for audioDeviceType in AudioDeviceType.allCases {
            let action = LocalUserAction.AudioDeviceChangeRequested(device: audioDeviceType)
            let audioDeviceOption = PopupMenuViewModel(
                icon: getAudioDeviceIcon(audioDeviceType),
                title: audioDeviceType.name,
                isSelected: isAudioDeviceSelected(audioDeviceType, selectedDevice: audioDeviceStatus),
                onSelected: { [weak self] in self?.dispatch(action) })
            audioDeviceOptions.append(audioDeviceOption)
        }

        return audioDeviceOptions
    }

    private func getAudioDeviceIcon(_ audioDeviceType: AudioDeviceType) -> CompositeIcon {
        let icon: CompositeIcon
        switch audioDeviceType {
        case .receiver:
            icon = .speakerRegular
        case .speaker:
            icon = .speakerFilled
        }
        return icon
    }

    private func isAudioDeviceSelected(_ audioDeviceType: AudioDeviceType,
                                       selectedDevice: LocalUserState.AudioDeviceSelectionStatus) -> Bool {
        let isSelected: Bool
        switch selectedDevice {
        case .receiverSelected where audioDeviceType == .receiver,
             .speakerSelected where audioDeviceType == .speaker:
            isSelected = true
        default:
            isSelected = false
        }
        return isSelected
    }
}

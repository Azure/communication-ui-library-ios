//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AVFoundation
import Combine

protocol AudioSessionManagerProtocol {

}

class AudioSessionManager: AudioSessionManagerProtocol {
    private let logger: Logger
    private let store: Store<AppState>
    private var localUserAudioDeviceState: LocalUserState.AudioDeviceSelectionStatus?
    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         logger: Logger) {
        self.store = store
        self.logger = logger
        let currentAudioDevice = getCurrentAudioDevice()
        self.setupAudioSession()
        store.dispatch(action: LocalUserAction.AudioDeviceChangeRequested(device: currentAudioDevice))
        store.$state
            .sink { [weak self] state in
                self?.receive(state: state)
            }.store(in: &cancellables)
    }

    private func receive(state: AppState) {
        let localUserState = state.localUserState
        let userAudioDeviceState = localUserState.audioState.device
        guard userAudioDeviceState != localUserAudioDeviceState else {
            return
        }
        localUserAudioDeviceState = userAudioDeviceState
        handle(state: userAudioDeviceState)
    }

    private func handle(state: LocalUserState.AudioDeviceSelectionStatus) {
        print("-----------handle state:\(state)")
        switch state {
        case .speakerRequested:
            switchAudioDevice(to: .speaker)
        case .receiverRequested:
            switchAudioDevice(to: .receiver)
        case .bluetoothRequested:
            switchAudioDevice(to: .bluetooth)
        case .headphonesRequested:
            switchAudioDevice(to: .headphones)
        default:
            break
        }
    }

    private func setupAudioSession() {

        activateAudioSessionCategory()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: typeValue),
              interruptionType == AVAudioSession.InterruptionType.ended else {
            return
        }
        resumeAudioSession()
    }

    @objc func handleRouteChange(notification: Notification) {
        let currentDevice = getCurrentAudioDevice()
        guard !hasProcess(currentDevice) else {
            return
        }

        store.dispatch(action: LocalUserAction.AudioDeviceChangeSucceeded(device: currentDevice))
    }

    private func activateAudioSessionCategory() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            let options: AVAudioSession.CategoryOptions = [.allowBluetooth,
                                                           .duckOthers,
                                                           .interruptSpokenAudioAndMixWithOthers,
                                                           .allowBluetoothA2DP]
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: options)
            try audioSession.setActive(true)
        } catch let error {
            logger.error("Failed to set audio session category:\(error.localizedDescription)")
        }
    }

    private func resumeAudioSession() {
        var audioDeviceType: AudioDeviceType
        switch localUserAudioDeviceState {
        case .receiverSelected,
                .receiverRequested:
            audioDeviceType = .receiver
        case .speakerSelected,
                .speakerRequested:
            audioDeviceType = .speaker
        case .headphonesSelected,
                .headphonesRequested:
            audioDeviceType = .headphones
        case .bluetoothSelected,
                .bluetoothRequested:
            audioDeviceType = .bluetooth
        default:
            audioDeviceType = .receiver
        }

        activateAudioSessionCategory()

        // Add a delay of setting audioDeviceType, to override the default port from setAudioSessionCategory.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.switchAudioDevice(to: audioDeviceType)
        }
    }

    private func getCurrentAudioDevice() -> AudioDeviceType {
        let audioSession = AVAudioSession.sharedInstance()

        if let output = audioSession.currentRoute.outputs.first {
            switch output.portType {
            case .bluetoothA2DP, .bluetoothLE, .bluetoothHFP:
                return .bluetooth
            case .headphones, .headsetMic:
                return .headphones
            case .builtInSpeaker:
                return .speaker
            default:
                return .receiver
            }
        }
        return .receiver
    }

    private func switchAudioDevice(to selectedAudioDevice: AudioDeviceType) {
        let audioSession = AVAudioSession.sharedInstance()

        let audioPort: AVAudioSession.PortOverride
        switch selectedAudioDevice {
        case .speaker:
            audioPort = .speaker
        case .receiver, .headphones, .bluetooth:
            audioPort = .none
        }

        do {
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(audioPort)
            store.dispatch(action: LocalUserAction.AudioDeviceChangeSucceeded(device: selectedAudioDevice))
        } catch let error {
            logger.error("Failed to select audio device, reason:\(error.localizedDescription)")
            store.dispatch(action: LocalUserAction.AudioDeviceChangeFailed(error: error))
        }
    }

    private func hasProcess(_ currentAudioDevice: AudioDeviceType) -> Bool {
        switch (localUserAudioDeviceState, currentAudioDevice) {
        case (.speakerSelected, .speaker),
            (.bluetoothSelected, .bluetooth),
            (.headphonesSelected, .headphones),
            (.receiverSelected, .receiver):
            return true
        default:
            return false
        }
    }
}

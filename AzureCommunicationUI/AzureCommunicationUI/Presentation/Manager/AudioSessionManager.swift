//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AVFoundation
import Combine

protocol AudioSessionManager {

}

class AppAudioSessionManager: AudioSessionManager {
    private let logger: Logger
    private let store: Store<AppState>
    var cancellables = Set<AnyCancellable>()
    var isSpeakerphoneOn: Bool = false

    init(store: Store<AppState>,
         logger: Logger) {
        self.store = store
        self.logger = logger
        initializeAudioDeviceState()
        self.setupAudioSession()
        store.$state
            .sink { [weak self] state in
                self?.receive(state: state)
            }.store(in: &cancellables)

    }

    private func initializeAudioDeviceState() {
        isSpeakerphoneOn = getCurrentAudioDevice() == .speaker
        if isSpeakerphoneOn {
             store.dispatch(action: LocalUserAction.AudioDeviceChangeSucceeded(device: .speaker))
        } else {
             store.dispatch(action: LocalUserAction.AudioDeviceChangeSucceeded(device: .receiver))
        }
    }

    private func receive(state: AppState) {
        let localUserState = state.localUserState
        handle(state: localUserState.audioState.device)
    }

    private func handle(state: LocalUserState.AudioDeviceSelectionStatus) {
        switch state {
        case .speakerRequested:
            switchAudioDevice(to: .speaker)
        case .receiverRequested:
            switchAudioDevice(to: .receiver)
        default:
            break
        }
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            let options: AVAudioSession.CategoryOptions = [.allowBluetooth,
                                                           .duckOthers,
                                                           .interruptSpokenAudioAndMixWithOthers,
                                                           .allowBluetoothA2DP]
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: options)
            try audioSession.overrideOutputAudioPort(isSpeakerphoneOn ? .speaker : .none)
            try audioSession.setActive(true)
        } catch let error {
            logger.error("Failed to set audio session category:\(error.localizedDescription)")
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
    }

    private func getCurrentAudioDevice() -> AudioDeviceType {
        let audioSession = AVAudioSession.sharedInstance()

        for output in audioSession.currentRoute.outputs where output.portType == .builtInSpeaker {
            return .speaker
        }
        return .receiver
    }

    private func switchAudioDevice(to selectedAudioDevice: AudioDeviceType) {
        let audioSession = AVAudioSession.sharedInstance()

        let audioPort: AVAudioSession.PortOverride
        switch selectedAudioDevice {
        case .receiver:
            audioPort = .none
        case .speaker:
            audioPort = .speaker
        }

        do {
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(audioPort)
            isSpeakerphoneOn = audioPort == .speaker
            store.dispatch(action: LocalUserAction.AudioDeviceChangeSucceeded(device: selectedAudioDevice))
        } catch let error {
            logger.error("Failed to select audio device, reason:\(error.localizedDescription)")
            store.dispatch(action: LocalUserAction.AudioDeviceChangeFailed(error: error))
            isSpeakerphoneOn = false
        }
    }

    @objc func handleRouteChange(notification: Notification) {
        store.dispatch(action: LocalUserAction.AudioDeviceChangeRequested(device: getCurrentAudioDevice()))
    }
}

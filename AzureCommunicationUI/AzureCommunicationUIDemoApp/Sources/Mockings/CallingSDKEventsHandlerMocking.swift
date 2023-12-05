//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
#if DEBUG
@testable import AzureCommunicationUICalling
@testable import AzureCommunicationCommon

class CallingSDKEventsHandlerMocking: CallingSDKEventsHandler {
    enum Constants {
        static let nanosecondsInSecond: UInt64 = 1_000_000_000
    }

    private var remoteParticipantsMocking: [ParticipantInfoModel] = []

    func joinCall() {
        Task { @MainActor [weak self] in
            try await Task<Never, Never>.sleep(nanoseconds: 2 * Constants.nanosecondsInSecond)

            self?.callInfoSubject.send(CallInfoModel(status: .connected,
                                                    internalError: nil))
        }
    }

    func joinLobby() {
        Task { @MainActor [weak self] in
            try await Task<Never, Never>.sleep(nanoseconds: 2 * Constants.nanosecondsInSecond)

            self?.callInfoSubject.send(CallInfoModel(status: .inLobby,
                                                    internalError: nil))
        }
    }

    func endCall() {
        Task { @MainActor [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .disconnected,
                                                    internalError: nil))
        }
    }

    func holdCall() {
        Task { @MainActor [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .localHold,
                                                    internalError: nil))
        }
    }

    func resumeCall() {
        Task { @MainActor [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .connected,
                                                    internalError: nil))
        }
    }

    func muteLocalMic() {
        Task { @MainActor [weak self] in
            self?.isLocalUserMutedSubject.send(true)
        }
    }

    func unmuteLocalMic() {
        Task { @MainActor [weak self] in
            self?.isLocalUserMutedSubject.send(false)
        }
    }

    func transcriptionOn() {
        Task { @MainActor [weak self] in
            self?.isTranscriptionActiveSubject.send(true)
        }
    }

    func transcriptionOff() {
        Task { @MainActor [weak self] in
            self?.isTranscriptionActiveSubject.send(false)
        }
    }

    func recordingOn() {
        Task { @MainActor [weak self] in
            self?.isRecordingActiveSubject.send(true)
        }
    }

    func recordingOff() {
        Task { @MainActor [weak self] in
            self?.isRecordingActiveSubject.send(false)
        }
    }

    func addParticipant() {
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            let participantNameIdentifier = "RM-\(self.remoteParticipantsMocking.count + 1)"
            let newParticipant = ParticipantInfoModel(displayName: participantNameIdentifier,
                                                      isSpeaking: false,
                                                      isMuted: true,
                                                      isRemoteUser: true,
                                                      userIdentifier: participantNameIdentifier,
                                                      status: .connected,
                                                      screenShareVideoStreamModel: nil,
                                                      cameraVideoStreamModel: nil)
            self.remoteParticipantsMocking.append(newParticipant)
            self.participantsInfoListSubject.send(self.remoteParticipantsMocking)
        }
    }

    func removeParticipant() {
        Task { @MainActor [weak self] in
            guard let self,
                  !self.remoteParticipantsMocking.isEmpty else {
                return
            }
            self.remoteParticipantsMocking.removeLast()
            self.participantsInfoListSubject.send(self.remoteParticipantsMocking)
        }
    }

    func unmuteParticipant() {
        Task { @MainActor [weak self] in
            guard let self,
                  !self.remoteParticipantsMocking.isEmpty else {
                return
            }
            let last = self.remoteParticipantsMocking.removeLast()
            let lastUnmuted = ParticipantInfoModel(displayName: last.displayName,
                                                   isSpeaking: last.isSpeaking,
                                                   isMuted: !last.isMuted,
                                                   isRemoteUser: last.isRemoteUser,
                                                   userIdentifier: last.userIdentifier,
                                                   status: last.status,
                                                   screenShareVideoStreamModel: last.screenShareVideoStreamModel,
                                                   cameraVideoStreamModel: last.cameraVideoStreamModel)
            self.remoteParticipantsMocking.append(lastUnmuted)
            self.participantsInfoListSubject.send(self.remoteParticipantsMocking)
        }
    }

    func holdParticipant() {
        Task { @MainActor [weak self] in
            guard let self,
                  !self.remoteParticipantsMocking.isEmpty else {
                return
            }
            let last = self.remoteParticipantsMocking.removeLast()
            let lastUnmuted = ParticipantInfoModel(displayName: last.displayName,
                                                   isSpeaking: last.isSpeaking,
                                                   isMuted: !last.isMuted,
                                                   isRemoteUser: last.isRemoteUser,
                                                   userIdentifier: last.userIdentifier,
                                                   status: .hold,
                                                   screenShareVideoStreamModel: last.screenShareVideoStreamModel,
                                                   cameraVideoStreamModel: last.cameraVideoStreamModel)
            self.remoteParticipantsMocking.append(lastUnmuted)
            self.participantsInfoListSubject.send(self.remoteParticipantsMocking)
        }
    }

    func emitMediaDiagnostic(_ diagnostic: MediaCallDiagnostic, value: Bool) {
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            self.mediaDiagnosticsSubject.send(
                MediaDiagnosticModel(diagnostic: diagnostic, value: value)
            )
        }
    }

    func emitNetworkQualityDiagnostic(_ diagnostic: NetworkQualityCallDiagnostic, value: CallDiagnosticQuality) {
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            self.networkQualityDiagnosticsSubject.send(
                NetworkQualityDiagnosticModel(diagnostic: diagnostic, value: value)
            )
        }
    }

    func emitNetworkDiagnostic(_ diagnostic: NetworkCallDiagnostic, value: Bool) {
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            self.networkDiagnosticsSubject.send(
                NetworkDiagnosticModel(diagnostic: diagnostic, value: value)
            )
        }
    }
}
#endif

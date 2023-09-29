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

    func addParticipant(status: ParticipantStatus = .connected) {
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
                                                      status: status,
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

    func admitAllLobbyParticipants() {
        Task { @MainActor [weak self] in
            guard let self,
                  !self.remoteParticipantsMocking.isEmpty else {
                return
            }

            let inLobbyParticipants = self.remoteParticipantsMocking.filter { participantInfoModel in
                participantInfoModel.status == .inLobby
            }

            self.remoteParticipantsMocking.removeAll { participantInfoModel in
                participantInfoModel.status == .inLobby
            }

            let connectedParticipants = inLobbyParticipants.map { participantInfoModel in
                ParticipantInfoModel(displayName: participantInfoModel.displayName,
                                     isSpeaking: participantInfoModel.isSpeaking,
                                     isMuted: participantInfoModel.isMuted,
                                     isRemoteUser: participantInfoModel.isRemoteUser,
                                     userIdentifier: participantInfoModel.userIdentifier,
                                     status: .connected,
                                     screenShareVideoStreamModel: participantInfoModel.screenShareVideoStreamModel,
                                     cameraVideoStreamModel: participantInfoModel.cameraVideoStreamModel)
            }

            self.remoteParticipantsMocking.append(contentsOf: connectedParticipants)
            self.participantsInfoListSubject.send(self.remoteParticipantsMocking)
        }
    }

    func admitLobbyParticipant(_ participantId: String) {
        Task { @MainActor [weak self] in
            guard let self,
                  !self.remoteParticipantsMocking.isEmpty else {
                return
            }

            let participantInfoModel = self.remoteParticipantsMocking.first { participantInfoModel in
                participantInfoModel.userIdentifier == participantId
            }

            guard let participantInfoModel = participantInfoModel else {
                return
            }

            self.remoteParticipantsMocking.removeAll { participantInfoModel in
                participantInfoModel.userIdentifier == participantId
            }

            let connectedParticipant =
                ParticipantInfoModel(displayName: participantInfoModel.displayName,
                                     isSpeaking: participantInfoModel.isSpeaking,
                                     isMuted: participantInfoModel.isMuted,
                                     isRemoteUser: participantInfoModel.isRemoteUser,
                                     userIdentifier: participantInfoModel.userIdentifier,
                                     status: .connected,
                                     screenShareVideoStreamModel: participantInfoModel.screenShareVideoStreamModel,
                                     cameraVideoStreamModel: participantInfoModel.cameraVideoStreamModel)

            self.remoteParticipantsMocking.append(connectedParticipant)
            self.participantsInfoListSubject.send(self.remoteParticipantsMocking)
        }
    }

    func declineLobbyParticipant(_ participantId: String) {
        Task { @MainActor [weak self] in
            guard let self,
                  !self.remoteParticipantsMocking.isEmpty else {
                return
            }

            self.remoteParticipantsMocking.removeAll { participantInfoModel in
                participantInfoModel.userIdentifier == participantId
            }
            self.participantsInfoListSubject.send(self.remoteParticipantsMocking)
        }
    }
}
#endif

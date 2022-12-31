//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
#if DEBUG
@testable import AzureCommunicationUICalling
@testable import AzureCommunicationCommon

class CallingSDKEventsHandlerMocking: CallingSDKEventsHandler {
    private var remoteParticipantsMocking: [ParticipantInfoModel] = []

    func joinCall() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .connected,
                                                     internalError: nil))
        }
    }

    func joinLobby() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .inLobby,
                                                     internalError: nil))
        }
    }

    func endCall() {
        DispatchQueue.main.async { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .disconnected,
                                               internalError: nil))
        }
    }

    func holdCall() {
        DispatchQueue.main.async { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .localHold,
                                               internalError: nil))
        }
    }

    func resumeCall() {
        DispatchQueue.main.async { [weak self] in
            self?.callInfoSubject.send(CallInfoModel(status: .connected,
                                               internalError: nil))
        }
    }

    func muteLocalMic() {
        DispatchQueue.main.async { [weak self] in
            self?.isLocalUserMutedSubject.send(true)
        }
    }

    func unmuteLocalMic() {
        DispatchQueue.main.async { [weak self] in
            self?.isLocalUserMutedSubject.send(false)
        }
    }

    func transcriptionOn() {
        DispatchQueue.main.async { [weak self] in
            self?.isTranscriptionActiveSubject.send(true)
        }
    }

    func transcriptionOff() {
        DispatchQueue.main.async { [weak self] in
            self?.isTranscriptionActiveSubject.send(false)
        }
    }

    func recordingOn() {
        DispatchQueue.main.async { [weak self] in
            self?.isRecordingActiveSubject.send(true)
        }
    }

    func recordingOff() {
        DispatchQueue.main.async { [weak self] in
            self?.isRecordingActiveSubject.send(false)
        }
    }

    func addParticipant() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let participantNameIdentifier = "RM-\(strongSelf.remoteParticipantsMocking.count + 1)"
            let newParticipant = ParticipantInfoModel(displayName: participantNameIdentifier,
                                                      isSpeaking: false,
                                                      isMuted: true,
                                                      isRemoteUser: true,
                                                      userIdentifier: participantNameIdentifier,
                                                      status: .connected, recentSpeakingStamp: Date(),
                                                      screenShareVideoStreamModel: nil,
                                                      cameraVideoStreamModel: nil)
            strongSelf.remoteParticipantsMocking.append(newParticipant)
            self?.participantsInfoListSubject.send(strongSelf.remoteParticipantsMocking)
        }
    }

    func removeParticipant() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, !strongSelf.remoteParticipantsMocking.isEmpty else {
                return
            }
            strongSelf.remoteParticipantsMocking.removeLast()
            self?.participantsInfoListSubject.send(strongSelf.remoteParticipantsMocking)
        }
    }

    func unmuteParticipant() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, !strongSelf.remoteParticipantsMocking.isEmpty else {
                return
            }
            let last = strongSelf.remoteParticipantsMocking.removeLast()
            let lastUnmuted = ParticipantInfoModel(displayName: last.displayName,
                                                   isSpeaking: last.isSpeaking,
                                                   isMuted: !last.isMuted,
                                                   isRemoteUser: last.isRemoteUser,
                                                   userIdentifier: last.userIdentifier,
                                                   status: last.status,
                                                   recentSpeakingStamp: last.recentSpeakingStamp,
                                                   screenShareVideoStreamModel: last.screenShareVideoStreamModel,
                                                   cameraVideoStreamModel: last.cameraVideoStreamModel)
            strongSelf.remoteParticipantsMocking.append(lastUnmuted)
            self?.participantsInfoListSubject.send(strongSelf.remoteParticipantsMocking)
        }
    }

    func holdParticipant() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, !strongSelf.remoteParticipantsMocking.isEmpty else {
                return
            }
            let last = strongSelf.remoteParticipantsMocking.removeLast()
            let lastUnmuted = ParticipantInfoModel(displayName: last.displayName,
                                                   isSpeaking: last.isSpeaking,
                                                   isMuted: !last.isMuted,
                                                   isRemoteUser: last.isRemoteUser,
                                                   userIdentifier: last.userIdentifier,
                                                   status: .hold,
                                                   recentSpeakingStamp: last.recentSpeakingStamp,
                                                   screenShareVideoStreamModel: last.screenShareVideoStreamModel,
                                                   cameraVideoStreamModel: last.cameraVideoStreamModel)
            strongSelf.remoteParticipantsMocking.append(lastUnmuted)
            self?.participantsInfoListSubject.send(strongSelf.remoteParticipantsMocking)
        }
    }
}
#endif

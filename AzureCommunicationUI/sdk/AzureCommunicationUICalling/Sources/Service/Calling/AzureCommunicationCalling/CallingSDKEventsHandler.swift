//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

import Foundation
import Combine

class CallingSDKEventsHandler: NSObject, CallingSDKEventsHandling {
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never> = .init([])
    var callInfoSubject = PassthroughSubject<CallInfoModel, Never>()
    var isRecordingActiveSubject = PassthroughSubject<Bool, Never>()
    var isTranscriptionActiveSubject = PassthroughSubject<Bool, Never>()
    var isLocalUserMutedSubject = PassthroughSubject<Bool, Never>()
    var callIdSubject = PassthroughSubject<String, Never>()

    private let logger: Logger
    private var remoteParticipantEventAdapter = RemoteParticipantsEventsAdapter()
    private var recordingCallFeature: RecordingCallFeature?
    private var transcriptionCallFeature: TranscriptionCallFeature?
    private var previousCallingStatus: CallingStatus = .none
    private var remoteParticipants = MappedSequence<String, AzureCommunicationCalling.RemoteParticipant>()

    init(logger: Logger) {
        self.logger = logger
        super.init()
        setupRemoteParticipantEventsAdapter()
    }

    func assign(_ recordingCallFeature: RecordingCallFeature) {
        self.recordingCallFeature = recordingCallFeature
        recordingCallFeature.delegate = self
    }

    func assign(_ transcriptionCallFeature: TranscriptionCallFeature) {
        self.transcriptionCallFeature = transcriptionCallFeature
        transcriptionCallFeature.delegate = self
    }

    func setupProperties() {
        participantsInfoListSubject.value.removeAll()
        recordingCallFeature = nil
        transcriptionCallFeature = nil
        remoteParticipants = MappedSequence<String, AzureCommunicationCalling.RemoteParticipant>()
        previousCallingStatus = .none
    }

    private func setupRemoteParticipantEventsAdapter() {
        let participantUpdate: ((AzureCommunicationCalling.RemoteParticipant)
                                -> Void) = { [weak self] remoteParticipant in
            guard let self = self else {
                return
            }
            let userIdentifier = remoteParticipant.identifier.rawId
            self.updateRemoteParticipant(userIdentifier: userIdentifier, updateSpeakingStamp: false)
        }

        remoteParticipantEventAdapter.onIsMutedChanged = participantUpdate
        remoteParticipantEventAdapter.onVideoStreamsUpdated = participantUpdate
        remoteParticipantEventAdapter.onStateChanged = participantUpdate

        remoteParticipantEventAdapter.onIsSpeakingChanged = { [weak self] remoteParticipant in
            guard let self = self else {
                return
            }
            let userIdentifier = remoteParticipant.identifier.rawId
            let updateSpeakingStamp = remoteParticipant.isSpeaking
            self.updateRemoteParticipant(userIdentifier: userIdentifier, updateSpeakingStamp: updateSpeakingStamp)
        }
    }

    private func removeRemoteParticipants(
        _ remoteParticipants: [AzureCommunicationCalling.RemoteParticipant]
    ) {
        for participant in remoteParticipants {
            let userIdentifier = participant.identifier.rawId
            self.remoteParticipants.removeValue(forKey: userIdentifier)?.delegate = nil
        }
        removeRemoteParticipantsInfoModel(remoteParticipants)
    }

    private func removeRemoteParticipantsInfoModel(
        _ remoteParticipants: [AzureCommunicationCalling.RemoteParticipant]
    ) {
        guard !remoteParticipants.isEmpty
        else { return }

        var remoteParticipantsInfoList = participantsInfoListSubject.value
        remoteParticipantsInfoList =
            remoteParticipantsInfoList.filter { infoModel in
                !remoteParticipants.contains(where: {
                    $0.identifier.rawId == infoModel.userIdentifier
                })
            }
        participantsInfoListSubject.send(remoteParticipantsInfoList)
    }

    private func addRemoteParticipants(
        _ remoteParticipants: [AzureCommunicationCalling.RemoteParticipant]
    ) {
        for participant in remoteParticipants {
            let userIdentifier = participant.identifier.rawId
            participant.delegate = remoteParticipantEventAdapter
            self.remoteParticipants.append(forKey: userIdentifier, value: participant)
        }
        addRemoteParticipantsInfoModel(remoteParticipants)
    }

    private func addRemoteParticipantsInfoModel(
        _ remoteParticipants: [AzureCommunicationCalling.RemoteParticipant]
    ) {
        guard !remoteParticipants.isEmpty
        else { return }

        var remoteParticipantsInfoList = participantsInfoListSubject.value
        remoteParticipants.forEach {
            let infoModel = $0.toParticipantInfoModel(recentSpeakingStamp: Date(timeIntervalSince1970: 0))
            remoteParticipantsInfoList.append(infoModel)
        }
        participantsInfoListSubject.send(remoteParticipantsInfoList)
    }

    private func updateRemoteParticipant(userIdentifier: String,
                                         updateSpeakingStamp: Bool) {
        var remoteParticipantsInfoList = participantsInfoListSubject.value
        if let remoteParticipant = remoteParticipants.value(forKey: userIdentifier),
           let index = remoteParticipantsInfoList.firstIndex(where: {
               $0.userIdentifier == userIdentifier
           }) {
            let speakingStamp = remoteParticipantsInfoList[index].recentSpeakingStamp
            let timeStamp = updateSpeakingStamp ? Date() : speakingStamp
            let newInfoModel = remoteParticipant.toParticipantInfoModel(recentSpeakingStamp: timeStamp)
            remoteParticipantsInfoList[index] = newInfoModel

            participantsInfoListSubject.send(remoteParticipantsInfoList)
        }
    }

    private func wasCallConnected() -> Bool {
        return previousCallingStatus == .connected ||
              previousCallingStatus == .localHold ||
              previousCallingStatus == .remoteHold
    }
}

extension CallingSDKEventsHandler: CallDelegate,
    RecordingCallFeatureDelegate,
    TranscriptionCallFeatureDelegate {
    func call(_ call: Call, didChangeId args: PropertyChangedEventArgs) {
        callIdSubject.send(call.id)
    }

    func call(_ call: Call, didUpdateRemoteParticipant args: ParticipantsUpdatedEventArgs) {
        if !args.removedParticipants.isEmpty {
            removeRemoteParticipants(args.removedParticipants)
        }
        if !args.addedParticipants.isEmpty {
            addRemoteParticipants(args.addedParticipants)
        }
    }

    func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        callIdSubject.send(call.id)

        let currentStatus = call.state.toCallingStatus()
        let internalError = call.callEndReason.toCompositeInternalError(wasCallConnected())
        if internalError != nil {
            let code = call.callEndReason.code
            let subcode = call.callEndReason.subcode
            logger.error("Receive vaildate CallEndReason:\(code), subcode:\(subcode)")
        }

        let callInfoModel = CallInfoModel(status: currentStatus,
                                          internalError: internalError)
        callInfoSubject.send(callInfoModel)
        self.previousCallingStatus = currentStatus
    }

    func recordingCallFeature(_ recordingCallFeature: RecordingCallFeature,
                              didChangeRecordingState args: PropertyChangedEventArgs) {
        let newRecordingActive = recordingCallFeature.isRecordingActive
        isRecordingActiveSubject.send(newRecordingActive)
    }

    func transcriptionCallFeature(_ transcriptionCallFeature: TranscriptionCallFeature,
                                  didChangeTranscriptionState args: PropertyChangedEventArgs) {
        let newTranscriptionActive = transcriptionCallFeature.isTranscriptionActive
        isTranscriptionActiveSubject.send(newTranscriptionActive)
    }

    func call(_ call: Call, didChangeMuteState args: PropertyChangedEventArgs) {
        isLocalUserMutedSubject.send(call.isMuted)
    }

}

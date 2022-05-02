//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling

protocol CallingSDKEventsHandling: CallDelegate {
    func assign(_ recordingCallFeature: RecordingCallFeature)
    func assign(_ transcriptionCallFeature: TranscriptionCallFeature)
    func setupProperties()

    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never> { get }
    var callInfoSubject: PassthroughSubject<CallInfoModel, Never> { get }
    var isRecordingActiveSubject: PassthroughSubject<Bool, Never> { get }
    var isTranscriptionActiveSubject: PassthroughSubject<Bool, Never> { get }
    var isLocalUserMutedSubject: PassthroughSubject<Bool, Never> { get }
}

class CallingSDKEventsHandler: NSObject, CallingSDKEventsHandling {
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never> = .init([])
    var callInfoSubject = PassthroughSubject<CallInfoModel, Never>()
    var isRecordingActiveSubject = PassthroughSubject<Bool, Never>()
    var isTranscriptionActiveSubject = PassthroughSubject<Bool, Never>()
    var isLocalUserMutedSubject = PassthroughSubject<Bool, Never>()

    private let logger: Logger
    private var remoteParticipantEventAdapter = RemoteParticipantsEventsAdapter()
    private var recordingCallFeature: RecordingCallFeature?
    private var transcriptionCallFeature: TranscriptionCallFeature?
    private var remoteParticipants = MappedSequence<String, RemoteParticipant>()
    private var previousCallingStatus: CallingStatus = .none

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
        remoteParticipants = MappedSequence<String, RemoteParticipant>()
        previousCallingStatus = .none
    }

    private func setupRemoteParticipantEventsAdapter() {
        remoteParticipantEventAdapter.onIsMutedChanged = { [weak self] remoteParticipant in
            guard let self = self,
                  let userIdentifier = remoteParticipant.identifier.stringValue else {
                return
            }
            self.updateRemoteParticipant(userIdentifier: userIdentifier, updateSpeakingStamp: false)
        }

        remoteParticipantEventAdapter.onIsSpeakingChanged = { [weak self] remoteParticipant in
            guard let self = self,
                  let userIdentifier = remoteParticipant.identifier.stringValue else {
                return
            }
            let updateSpeakingStamp = remoteParticipant.isSpeaking
            self.updateRemoteParticipant(userIdentifier: userIdentifier, updateSpeakingStamp: updateSpeakingStamp)
        }

        remoteParticipantEventAdapter.onVideoStreamsUpdated = { [weak self] remoteParticipant in
            guard let self = self,
                  let userIdentifier = remoteParticipant.identifier.stringValue else {
                return
            }
            self.updateRemoteParticipant(userIdentifier: userIdentifier, updateSpeakingStamp: false)
        }
    }

    private func removeRemoteParticipants(_ remoteParticipants: [RemoteParticipant]) {
        for participant in remoteParticipants {
            if let userIdentifier = participant.identifier.stringValue {
                self.remoteParticipants.removeValue(forKey: userIdentifier)?.delegate = nil
            }
        }
        removeRemoteParticipantsInfoModel(remoteParticipants)
    }

    private func removeRemoteParticipantsInfoModel(_ remoteParticipants: [RemoteParticipant]) {
        var remoteParticipantsInfoList = participantsInfoListSubject.value
        remoteParticipantsInfoList =
            remoteParticipantsInfoList.filter { infoModel in
                !remoteParticipants.contains(where: {
                    $0.identifier.stringValue == infoModel.userIdentifier
                })
            }
        participantsInfoListSubject.send(remoteParticipantsInfoList)
    }

    private func addRemoteParticipants(_ remoteParticipants: [RemoteParticipant]) {
        for participant in remoteParticipants {
            if let userIdentifier = participant.identifier.stringValue {
                participant.delegate = remoteParticipantEventAdapter
                self.remoteParticipants.append(forKey: userIdentifier, value: participant)
            }
        }
        addRemoteParticipantsInfoModel(remoteParticipants)
    }

    private func addRemoteParticipantsInfoModel(_ remoteParticipants: [RemoteParticipant]) {
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
}

extension CallingSDKEventsHandler: CallDelegate,
    RecordingCallFeatureDelegate,
    TranscriptionCallFeatureDelegate {
    func call(_ call: Call, didUpdateRemoteParticipant args: ParticipantsUpdatedEventArgs) {
        removeRemoteParticipants(args.removedParticipants)
        addRemoteParticipants(args.addedParticipants)
    }

    func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        let currentStatus = call.state.toCallingStatus()
        let errorCode = determineErrorType(previousStatus: self.previousCallingStatus,
                                           callEndReason: call.callEndReason)

        let callInfoModel = CallInfoModel(status: currentStatus, errorCode: errorCode)
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

    private func determineErrorType(previousStatus: CallingStatus, callEndReason: CallEndReason) -> String {
        let callEndReasonCode = callEndReason.code
        let callEndReasonSubCode = callEndReason.subcode

        if callEndReasonCode == 0 {
            if (callEndReasonSubCode == 5300 || callEndReasonSubCode == 5000),
                previousStatus == .connected {
                return InternalCallCompositeErrorCode.callEvicted
            }
        } else if callEndReasonCode > 0 {
            if callEndReasonCode == 401 {
                return CallCompositeErrorCode.tokenExpired
            } else if callEndReasonCode == 487 {
                // having "" will leave the composite
                return ""
            } else {
                return previousStatus == .connected
                ? CallCompositeErrorCode.callEnd
                : CallCompositeErrorCode.callJoin
            }
        }

        return ""
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

import Foundation
import Combine

// swiftlint:disable file_length
class CallingSDKEventsHandler: NSObject, CallingSDKEventsHandling {
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never> = .init([])
    var callInfoSubject = PassthroughSubject<CallInfoModel, Never>()
    var isRecordingActiveSubject = PassthroughSubject<Bool, Never>()
    var isTranscriptionActiveSubject = PassthroughSubject<Bool, Never>()
    var dominantSpeakersSubject: CurrentValueSubject<[String], Never> = .init([])
    var isLocalUserMutedSubject = PassthroughSubject<Bool, Never>()
    var callIdSubject = PassthroughSubject<String, Never>()
    var participantRoleSubject = PassthroughSubject<ParticipantRoleEnum, Never>()
    var totalParticipantCountSubject = PassthroughSubject<Int, Never>()
    /* <CALL_START_TIME>
    var callStartTimeSubject = PassthroughSubject<Date, Never>()
    </CALL_START_TIME> */
    var capabilitiesChangedSubject = PassthroughSubject<CapabilitiesChangedEvent, Never>()

    var captionsSupportedSpokenLanguages = CurrentValueSubject<[String], Never>([])
    var captionsSupportedCaptionLanguages = CurrentValueSubject<[String], Never>([])
    var isCaptionsTranslationSupported = CurrentValueSubject<Bool, Never>(false)
    var captionsReceived = PassthroughSubject<CallCompositeCaptionsData, Never>()
    var rttReceived = PassthroughSubject<CallCompositeRttData, Never>()
    var activeSpokenLanguageChanged = CurrentValueSubject<String, Never>("")
    var activeCaptionLanguageChanged = CurrentValueSubject<String, Never>("")
    var captionsEnabledChanged = CurrentValueSubject<Bool, Never>(false)
    var captionsTypeChanged = CurrentValueSubject<CallCompositeCaptionsType, Never>(.none)

    // User Facing Diagnostics Subjects
    var networkQualityDiagnosticsSubject = PassthroughSubject<NetworkQualityDiagnosticModel, Never>()
    var networkDiagnosticsSubject = PassthroughSubject<NetworkDiagnosticModel, Never>()
    var mediaDiagnosticsSubject = PassthroughSubject<MediaDiagnosticModel, Never>()

    private let logger: Logger
    private var remoteParticipantEventAdapter = RemoteParticipantsEventsAdapter()

    private var recordingCallFeature: RecordingCallFeature?
    private var transcriptionCallFeature: TranscriptionCallFeature?
    private var dominantSpeakersCallFeature: DominantSpeakersCallFeature?
    private var localUserDiagnosticsFeature: LocalUserDiagnosticsCallFeature?
    private var captionsFeature: CaptionsCallFeature?
    private var teamsCaptions: TeamsCaptions?
    private var communicationCaptions: CommunicationCaptions?
    private var capabilitiesCallFeature: CapabilitiesCallFeature?
    private var realTimeTextCallFeature: RealTimeTextCallFeature?

    private var previousCallingStatus: CallingStatus = .none
    private var remoteParticipants = MappedSequence<String, AzureCommunicationCalling.RemoteParticipant>()

    private let communicationCaptionsHandler = CommunicationCaptionsHandler()
    private let teamsCaptionsHandler = TeamsCaptionsHandler()

    init(logger: Logger) {
        self.logger = logger
        super.init()
        setupRemoteParticipantEventsAdapter()
        communicationCaptionsHandler.parentHandler = self
        teamsCaptionsHandler.parentHandler = self
    }

    func assign(_ recordingCallFeature: RecordingCallFeature) {
        self.recordingCallFeature = recordingCallFeature
        recordingCallFeature.delegate = self
    }

    func assign(_ transcriptionCallFeature: TranscriptionCallFeature) {
        self.transcriptionCallFeature = transcriptionCallFeature
        transcriptionCallFeature.delegate = self
    }

    func assign(_ dominantSpeakersCallFeature: DominantSpeakersCallFeature) {
        self.dominantSpeakersCallFeature = dominantSpeakersCallFeature
        dominantSpeakersCallFeature.delegate = self
    }

    func assign(_ localUserDiagnosticsFeature: LocalUserDiagnosticsCallFeature) {
        self.localUserDiagnosticsFeature = localUserDiagnosticsFeature
        localUserDiagnosticsFeature.mediaDiagnostics.delegate = self
        localUserDiagnosticsFeature.networkDiagnostics.delegate = self
    }

    func assign(_ captionsFeature: CaptionsCallFeature) {
        self.captionsFeature = captionsFeature
        captionsFeature.delegate = self
    }

    func assign(_ capabilitiesCallFeature: CapabilitiesCallFeature) {
        self.capabilitiesCallFeature = capabilitiesCallFeature
        self.capabilitiesCallFeature?.delegate = self
    }

    func assign(_ realTimeTextCallFeature: RealTimeTextCallFeature) {
        self.realTimeTextCallFeature = realTimeTextCallFeature
        realTimeTextCallFeature.delegate = self
    }

    func setupProperties() {
        participantsInfoListSubject.value.removeAll()
        recordingCallFeature = nil
        transcriptionCallFeature = nil
        dominantSpeakersCallFeature = nil
        localUserDiagnosticsFeature = nil
        captionsFeature = nil
        realTimeTextCallFeature = nil
        remoteParticipants = MappedSequence<String, AzureCommunicationCalling.RemoteParticipant>()
        previousCallingStatus = .none
        capabilitiesCallFeature = nil
    }

    private func setupRemoteParticipantEventsAdapter() {
        let participantUpdate: ((AzureCommunicationCalling.RemoteParticipant)
                                -> Void) = { [weak self] remoteParticipant in
            guard let self = self else {
                return
            }
            let userIdentifier = remoteParticipant.identifier.rawId
            self.updateRemoteParticipant(userIdentifier: userIdentifier)
        }

        remoteParticipantEventAdapter.onIsMutedChanged = participantUpdate
        remoteParticipantEventAdapter.onVideoStreamsUpdated = participantUpdate
        remoteParticipantEventAdapter.onStateChanged = participantUpdate
        remoteParticipantEventAdapter.onDominantSpeakersChanged = participantUpdate
        remoteParticipantEventAdapter.onIsSpeakingChanged = { [weak self] remoteParticipant in
            guard let self = self else {
                return
            }
            let userIdentifier = remoteParticipant.identifier.rawId
            _ = remoteParticipant.isSpeaking
            self.updateRemoteParticipant(userIdentifier: userIdentifier)
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
        var remoteParticipantsInfoList = participantsInfoListSubject.value
        for participant in remoteParticipants {
            let userIdentifier = participant.identifier.rawId
            if self.remoteParticipants.value(forKey: userIdentifier) == nil {
                participant.delegate = remoteParticipantEventAdapter
                self.remoteParticipants.append(forKey: userIdentifier, value: participant)
                let infoModel = participant.toParticipantInfoModel()
                remoteParticipantsInfoList.append(infoModel)
            }
        }
        participantsInfoListSubject.send(remoteParticipantsInfoList)
    }

    private func updateRemoteParticipant(userIdentifier: String) {
        var remoteParticipantsInfoList = participantsInfoListSubject.value
        if let remoteParticipant = remoteParticipants.value(forKey: userIdentifier),
           let index = remoteParticipantsInfoList.firstIndex(where: {
               $0.userIdentifier == userIdentifier
           }) {
            let newInfoModel = remoteParticipant.toParticipantInfoModel()
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
    TranscriptionCallFeatureDelegate,
    DominantSpeakersCallFeatureDelegate,
    MediaDiagnosticsDelegate,
    NetworkDiagnosticsDelegate,
    CaptionsCallFeatureDelegate,
    RealTimeTextCallFeatureDelegate,
    CapabilitiesCallFeatureDelegate {
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

    /* <CALL_START_TIME>
    func call(_ call: Call, didUpdateStartTime args: PropertyChangedEventArgs) {
        callStartTimeSubject.send(call.startTime)
    }
    </CALL_START_TIME> */

    func call(_ call: Call, didChangeState args: PropertyChangedEventArgs) {
        onStateChanged(call: call)
    }

    func onStateChanged(call: Call) {
        callIdSubject.send(call.id)
        let currentStatus = call.state.toCallingStatus()
        let internalError = call.callEndReason.toCompositeInternalError(wasCallConnected())
        if internalError != nil {
            let code = call.callEndReason.code
            let subcode = call.callEndReason.subcode
            logger.error("Receive vaildate CallEndReason:\(code), subcode:\(subcode)")
        }
        if currentStatus == .connected {
            self.captionsFeature = call.feature(Features.captions)
            self.captionsFeature?.getCaptions {(value, error) in
                if let error = error {
                    self.logger.error("Can not get the captions with error:\(error)")
                } else {
                    if value?.type == CaptionsType.communicationCaptions {
                        // communication captions
                        self.communicationCaptions = value as? CommunicationCaptions
                        self.communicationCaptions?.delegate = self.communicationCaptionsHandler
                        self.captionsSupportedSpokenLanguages.send(self.communicationCaptions?
                            .supportedSpokenLanguages ?? [])
                        self.captionsTypeChanged.send(.communication)
                    }

                    if value?.type == CaptionsType.teamsCaptions {
                        // teams captions
                        self.teamsCaptions = value as? TeamsCaptions
                        self.teamsCaptions?.delegate = self.teamsCaptionsHandler
                        self.captionsSupportedSpokenLanguages.send(self.teamsCaptions?.supportedSpokenLanguages ?? [])
                        self.captionsSupportedCaptionLanguages.send(self.teamsCaptions?.supportedCaptionLanguages ?? [])
                        self.captionsTypeChanged.send(.teams)
                    }
                }
            }
        }
        let callInfoModel = CallInfoModel(status: currentStatus,
                                          internalError: internalError,
                                          callEndReasonCode: Int(call.callEndReason.code),
                                          callEndReasonSubCode: Int(call.callEndReason.subcode))
        logger.debug( "callInfoModel \(callInfoModel.status)")
        logger.debug( "remoteParticipants \(call.remoteParticipants.count)")
        callInfoSubject.send(callInfoModel)
        if currentStatus == .connected || currentStatus == .connecting {
            addRemoteParticipants(call.remoteParticipants)
        }
        if currentStatus == .disconnected {
            call.delegate = nil
        }
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

    func realTimeTextCallFeature(_ realTextCallFeature: RealTimeTextCallFeature,
                                 didReceiveInfo args: RealTimeTextInfoReceivedEventArgs) {
        let rttMessage = args.info.toCallCompositeRttData()

        if let index = participantsInfoListSubject.value.firstIndex(where: {
            $0.userIdentifier == rttMessage.senderRawId
        }) {
            // Update the participant in place
            var updatedList = participantsInfoListSubject.value
            updatedList[index].isTypingRtt = rttMessage.resultType != .final && !rttMessage.text.isEmpty

            self.participantsInfoListSubject.send(updatedList)
        }
        rttReceived.send(rttMessage)
    }

    func dominantSpeakersCallFeature(_ dominantSpeakersCallFeature: DominantSpeakersCallFeature,
                                     didChangeDominantSpeakers args: PropertyChangedEventArgs) {
        let dominantSpeakersInfo = dominantSpeakersCallFeature.dominantSpeakersInfo
        var speakers = [String]()
        for speaker in dominantSpeakersInfo.speakers {
            let userIdentifier = speaker.rawId
            speakers.append(userIdentifier)
        }
        dominantSpeakersSubject.send(speakers)
    }

    func call(_ call: Call, didChangeMuteState args: PropertyChangedEventArgs) {
        isLocalUserMutedSubject.send(call.isOutgoingAudioMuted)
    }

    func call(_ call: Call, didChangeRole args: PropertyChangedEventArgs) {
        let role = call.callParticipantRole.toParticipantRole()
        participantRoleSubject.send(role)
    }

    func call(_ call: Call, didChangeTotalParticipantCount args: PropertyChangedEventArgs) {
        // substract local participant from total participantCount
        totalParticipantCountSubject.send(Int(call.totalParticipantCount) - 1)
    }

    // MARK: CapabilitiesDelegate
    func capabilitiesCallFeature(_ capabilitiesCallFeature: CapabilitiesCallFeature,
                                 didChangeCapabilities args: CapabilitiesChangedEventArgs) {
        let capabilitiesChangedEvent = args.toCapabilitiesChangedEvent()
        self.capabilitiesChangedSubject.send(capabilitiesChangedEvent)
    }

    // MARK: NetworkDiagnosticsDelegate
    func networkDiagnostics(_ networkDiagnostics: NetworkDiagnostics,
                            didChangeNetworkSendQuality args: DiagnosticQualityChangedEventArgs) {
        let model = NetworkQualityDiagnosticModel(
            diagnostic: .networkSendQuality,
            value: args.value.toCallCompositeDiagnosticQuality()
        )
        self.networkQualityDiagnosticsSubject.send(model)
    }

    func networkDiagnostics(_ networkDiagnostics: NetworkDiagnostics,
                            didChangeNetworkReconnectionQuality args: DiagnosticQualityChangedEventArgs) {
        let model = NetworkQualityDiagnosticModel(
            diagnostic: .networkReconnectionQuality,
            value: args.value.toCallCompositeDiagnosticQuality()
        )
        self.networkQualityDiagnosticsSubject.send(model)
    }

    func networkDiagnostics(_ networkDiagnostics: NetworkDiagnostics,
                            didChangeNetworkReceiveQuality args: DiagnosticQualityChangedEventArgs) {
        let model = NetworkQualityDiagnosticModel(
            diagnostic: .networkReceiveQuality,
            value: args.value.toCallCompositeDiagnosticQuality()
        )
        self.networkQualityDiagnosticsSubject.send(model)
    }

    func networkDiagnostics(_ networkDiagnostics: NetworkDiagnostics,
                            didChangeIsNetworkUnavailable args: DiagnosticFlagChangedEventArgs) {
        let model = NetworkDiagnosticModel(diagnostic: .networkUnavailable, value: args.value)
        self.networkDiagnosticsSubject.send(model)
    }

    func networkDiagnostics(_ networkDiagnostics: NetworkDiagnostics,
                            didChangeIsNetworkRelaysUnreachable args: DiagnosticFlagChangedEventArgs) {
        let model = NetworkDiagnosticModel(diagnostic: .networkRelaysUnreachable, value: args.value)
        self.networkDiagnosticsSubject.send(model)
    }

    // MARK: MediaDiagnosticsDelegate
    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsSpeakerBusy args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .speakerBusy, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsCameraFrozen args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .cameraFrozen, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsSpeakerMuted args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .speakerMuted, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsMicrophoneBusy args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .microphoneBusy, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsCameraStartFailed args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .cameraStartFailed, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsSpeakerVolumeZero args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .speakerVolumeZero, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsSpeakerNotFunctioning args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .speakerNotFunctioning, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsCameraPermissionDenied args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .cameraPermissionDenied, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsMicrophoneNotFunctioning args: DiagnosticFlagChangedEventArgs) {
        // .microphoneNotFunctioning is unhandled for now because there is a false positive
        // event from SDK that is fixed, but pending release.
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsCameraStartTimedOut args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .cameraStartTimedOut, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsMicrophoneMutedUnexpectedly args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .microphoneMutedUnexpectedly, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsNoSpeakerDevicesAvailable args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .noSpeakerDevicesAvailable, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsNoMicrophoneDevicesAvailable args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .noMicrophoneDevicesAvailable, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }

    func mediaDiagnostics(_ mediaDiagnostics: MediaDiagnostics,
                          didChangeIsSpeakingWhileMicrophoneIsMuted args: DiagnosticFlagChangedEventArgs) {
        let model = MediaDiagnosticModel(diagnostic: .speakingWhileMicrophoneIsMuted, value: args.value)
        self.mediaDiagnosticsSubject.send(model)
    }
}

private class CommunicationCaptionsHandler: NSObject, CommunicationCaptionsDelegate {
    weak var parentHandler: CallingSDKEventsHandler?

    func communicationCaptions(_ communicationCaptions: CommunicationCaptions,
                               didReceiveCaptions: CommunicationCaptionsReceivedEventArgs) {
        parentHandler?.captionsReceived.send(didReceiveCaptions.toCallCompositeCaptionsData())
    }

    func communicationCaptions(_ communicationCaptions: CommunicationCaptions,
                               didChangeActiveSpokenLanguageState args: PropertyChangedEventArgs) {
        let spokenLanguage = communicationCaptions.activeSpokenLanguage
        parentHandler?.activeSpokenLanguageChanged.send(spokenLanguage)
    }

   func communicationCaptions(_ communicationCaptions: CommunicationCaptions,
                              didChangeCaptionsEnabledState args: PropertyChangedEventArgs) {
        let isCaptionsEnabled = communicationCaptions.isEnabled
       parentHandler?.captionsEnabledChanged.send(isCaptionsEnabled)
    }
}

private class TeamsCaptionsHandler: NSObject, TeamsCaptionsDelegate {
    weak var parentHandler: CallingSDKEventsHandler?

    func teamsCaptions(_ teamsCaptions: TeamsCaptions,
                       didChangeCaptionsEnabledState args: PropertyChangedEventArgs) {
        parentHandler?.captionsEnabledChanged.send(teamsCaptions.isEnabled)
    }

    func teamsCaptions(_ teamsCaptions: TeamsCaptions,
                       didChangeActiveSpokenLanguageState args: PropertyChangedEventArgs) {
        let spokenLanguage = teamsCaptions.activeSpokenLanguage
        parentHandler?.activeSpokenLanguageChanged.send(spokenLanguage)
    }

    func teamsCaptions(_ teamsCaptions: TeamsCaptions,
                       didReceiveCaptions args: TeamsCaptionsReceivedEventArgs) {
        parentHandler?.captionsReceived.send(args.toCallCompositeCaptionsData())
    }

    func teamsCaptions(_ teamsCaptions: TeamsCaptions,
                       didChangeActiveCaptionLanguageState args: PropertyChangedEventArgs) {
        let captionsLanguage = teamsCaptions.activeCaptionLanguage
        parentHandler?.activeCaptionLanguageChanged.send(captionsLanguage)
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
@testable import AzureCommunicationUICalling

class CallingSDKEventsHandlerMocking: NSObject, CallingSDKEventsHandling {
    var captionsSupportedSpokenLanguages: CurrentValueSubject<[String], Never>
    var captionsSupportedCaptionLanguages: CurrentValueSubject<[String], Never>
    var isCaptionsTranslationSupported: CurrentValueSubject<Bool, Never>
    var captionsReceived: PassthroughSubject<AzureCommunicationUICalling.CallCompositeCaptionsData, Never>
    var activeSpokenLanguageChanged: CurrentValueSubject<String, Never>
    var activeCaptionLanguageChanged: CurrentValueSubject<String, Never>
    var captionsEnabledChanged: CurrentValueSubject<Bool, Never>
    var captionsTypeChanged: CurrentValueSubject<AzureCommunicationUICalling.CallCompositeCaptionsType, Never>
    var participantsInfoListSubject: CurrentValueSubject<[ParticipantInfoModel], Never>
    var callInfoSubject: PassthroughSubject<CallInfoModel, Never>
    var isRecordingActiveSubject: PassthroughSubject<Bool, Never>
    var isTranscriptionActiveSubject: PassthroughSubject<Bool, Never>
    var isLocalUserMutedSubject: PassthroughSubject<Bool, Never>
    var callIdSubject: PassthroughSubject<String, Never>
    var dominantSpeakersSubject: CurrentValueSubject<[String], Never>
    var dominantSpeakersModifiedTimestampSubject: PassthroughSubject<Date, Never>
    var participantRoleSubject: PassthroughSubject<ParticipantRoleEnum, Never>
    var networkQualityDiagnosticsSubject: PassthroughSubject<NetworkQualityDiagnosticModel, Never>
    var networkDiagnosticsSubject: PassthroughSubject<NetworkDiagnosticModel, Never>
    var mediaDiagnosticsSubject: PassthroughSubject<MediaDiagnosticModel, Never>
    var capabilitiesChangedSubject = PassthroughSubject<AzureCommunicationUICalling.CapabilitiesChangedEvent, Never>()
    var totalParticipantCountSubject = PassthroughSubject<Int, Never>()
    var rttReceived: PassthroughSubject<AzureCommunicationUICalling.CallCompositeRttData, Never> = PassthroughSubject<AzureCommunicationUICalling.CallCompositeRttData, Never>()
    /* <CALL_START_TIME>
    var callStartTimeSubject = PassthroughSubject<Date, Never>()
    </CALL_START_TIME> */

    override init() {
        captionsSupportedSpokenLanguages = CurrentValueSubject<[String], Never>([])
        captionsSupportedCaptionLanguages = CurrentValueSubject<[String], Never>([])
        isCaptionsTranslationSupported = CurrentValueSubject<Bool, Never>(false)
        captionsReceived = PassthroughSubject<AzureCommunicationUICalling.CallCompositeCaptionsData, Never>()
        activeSpokenLanguageChanged = CurrentValueSubject<String, Never>("")
        activeCaptionLanguageChanged = CurrentValueSubject<String, Never>("")
        captionsEnabledChanged = CurrentValueSubject<Bool, Never>(false)
        captionsTypeChanged = CurrentValueSubject<AzureCommunicationUICalling.CallCompositeCaptionsType, Never>(.none)
        participantsInfoListSubject = CurrentValueSubject<[ParticipantInfoModel], Never>([])
        callInfoSubject = PassthroughSubject<CallInfoModel, Never>()
        isRecordingActiveSubject = PassthroughSubject<Bool, Never>()
        isTranscriptionActiveSubject = PassthroughSubject<Bool, Never>()
        isLocalUserMutedSubject = PassthroughSubject<Bool, Never>()
        callIdSubject = PassthroughSubject<String, Never>()
        dominantSpeakersSubject = CurrentValueSubject<[String], Never>([])
        dominantSpeakersModifiedTimestampSubject = PassthroughSubject<Date, Never>()
        participantRoleSubject = PassthroughSubject<ParticipantRoleEnum, Never>()
        networkQualityDiagnosticsSubject = PassthroughSubject<NetworkQualityDiagnosticModel, Never>()
        networkDiagnosticsSubject = PassthroughSubject<NetworkDiagnosticModel, Never>()
        mediaDiagnosticsSubject = PassthroughSubject<MediaDiagnosticModel, Never>()

        super.init()
    }
}

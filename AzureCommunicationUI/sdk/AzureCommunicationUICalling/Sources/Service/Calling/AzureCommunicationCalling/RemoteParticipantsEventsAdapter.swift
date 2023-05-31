//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

class RemoteParticipantsEventsAdapter: NSObject, RemoteParticipantDelegate {
    var onVideoStreamsUpdated: ((AzureCommunicationCalling.RemoteParticipant) -> Void) = {_ in }
    var onIsSpeakingChanged: ((AzureCommunicationCalling.RemoteParticipant) -> Void) = {_ in }
    var onDominantSpeakersChanged: ((AzureCommunicationCalling.RemoteParticipant) -> Void) = {_ in }
    var onIsMutedChanged: ((AzureCommunicationCalling.RemoteParticipant) -> Void) = {_ in }
    var onStateChanged: ((AzureCommunicationCalling.RemoteParticipant) -> Void) = {_ in }
    func remoteParticipant(_ remoteParticipant: AzureCommunicationCalling.RemoteParticipant,
                           didChangeSpeakingState args: PropertyChangedEventArgs) {
        onIsSpeakingChanged(remoteParticipant)
    }
    func remoteParticipant(_ remoteParticipant: AzureCommunicationCalling.RemoteParticipant,
                           didChangeDominantSpeakerState args: PropertyChangedEventArgs) {
        onDominantSpeakersChanged(remoteParticipant)
    }
    func remoteParticipant(_ remoteParticipant: AzureCommunicationCalling.RemoteParticipant,
                           didChangeMuteState args: PropertyChangedEventArgs) {
        onIsMutedChanged(remoteParticipant)
    }

    func remoteParticipant(_ remoteParticipant: AzureCommunicationCalling.RemoteParticipant,
                           didChangeState args: PropertyChangedEventArgs) {

        onStateChanged(remoteParticipant)
    }
}

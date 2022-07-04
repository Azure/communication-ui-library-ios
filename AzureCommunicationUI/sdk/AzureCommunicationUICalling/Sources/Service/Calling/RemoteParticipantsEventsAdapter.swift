//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling

class RemoteParticipantsEventsAdapter: NSObject, RemoteParticipantDelegate {
    var onVideoStreamsUpdated: ((RemoteParticipant) -> Void) = {_ in }
    var onIsSpeakingChanged: ((RemoteParticipant) -> Void) = {_ in }
    var onIsMutedChanged: ((RemoteParticipant) -> Void) = {_ in }
    var onStateChanged: ((RemoteParticipant) -> Void) = {_ in }

    func remoteParticipant(_ remoteParticipant: RemoteParticipant,
                           didUpdateVideoStreams args: RemoteVideoStreamsEventArgs) {
        onVideoStreamsUpdated(remoteParticipant)
    }

    func remoteParticipant(_ remoteParticipant: RemoteParticipant,
                           didChangeSpeakingState args: PropertyChangedEventArgs) {
        onIsSpeakingChanged(remoteParticipant)
    }

    func remoteParticipant(_ remoteParticipant: RemoteParticipant,
                           didChangeMuteState args: PropertyChangedEventArgs) {
        onIsMutedChanged(remoteParticipant)
    }

    func remoteParticipant(_ remoteParticipant: RemoteParticipant,
                           didChangeState args: PropertyChangedEventArgs) {

        onStateChanged(remoteParticipant)
    }
}

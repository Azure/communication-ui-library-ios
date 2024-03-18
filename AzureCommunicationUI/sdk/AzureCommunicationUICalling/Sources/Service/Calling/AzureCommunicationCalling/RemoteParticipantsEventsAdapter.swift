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

    var onVideoStreamStateChanged: ((AzureCommunicationCalling.RemoteParticipant) -> Void) = {_ in }
    var onVideoFrameRecieved: (((AzureCommunicationCalling.RemoteParticipant), CVPixelBuffer) -> Void) = {_, _ in }

    private let rawVideoStreams = MappedSequence<Int32, RawIncomingVideoStreamD>()

    func remoteParticipant(_ remoteParticipant: AzureCommunicationCalling.RemoteParticipant,
                           didUpdateVideoStreams args: RemoteVideoStreamsEventArgs) {
        onVideoStreamsUpdated(remoteParticipant)
    }
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

    func remoteParticipant(_ remoteParticipant: RemoteParticipant,
                           didChangeVideoStreamState args: VideoStreamStateChangedEventArgs) {
            if let rawIncomingVideoStream = args.stream as? RawIncomingVideoStream {
                onRawIncomingVideoStreamStateChanged(remoteParticipant, rawIncomingVideoStream: rawIncomingVideoStream)
            }
        }

        func onRawIncomingVideoStreamStateChanged(_ remoteParticipant: RemoteParticipant,
                                                  rawIncomingVideoStream: RawIncomingVideoStream) {
            switch rawIncomingVideoStream.state {
            case .available:
                /* There is a new IncomingVideoStream */
                let videoStreamDelegate = RawIncomingVideoStreamD(remoteParticipant: remoteParticipant,
                                                                  remoteParticipantsEventsAdapter: self)
                rawVideoStreams.append(forKey: rawIncomingVideoStream.id, value: videoStreamDelegate)
                rawIncomingVideoStream.delegate = videoStreamDelegate

                rawIncomingVideoStream.start()
            case .started:
                /* Will start receiving video frames */
                break
            case .stopped, .stopping:
                /* Will stop receiving video frames */
                onStateChanged(remoteParticipant)
            case .notAvailable:
                /* The IncomingVideoStream should not be used anymore */
                rawIncomingVideoStream.delegate = nil
                rawVideoStreams.removeValue(forKey: rawIncomingVideoStream.id)
                onStateChanged(remoteParticipant)
            default:
                break
            }
        }

        class RawIncomingVideoStreamD: NSObject, RawIncomingVideoStreamDelegate {
            private let remoteParticipantsEventsAdapter: RemoteParticipantsEventsAdapter
            private let remoteParticipant: RemoteParticipant

            init(remoteParticipant: RemoteParticipant,
                 remoteParticipantsEventsAdapter: RemoteParticipantsEventsAdapter) {
                self.remoteParticipantsEventsAdapter = remoteParticipantsEventsAdapter
                self.remoteParticipant = remoteParticipant
            }

            func rawIncomingVideoStream(_ rawIncomingVideoStream: RawIncomingVideoStream,
                                        didReceiveRawVideoFrame args: RawVideoFrameReceivedEventArgs) {

                if let videoFrameBuffer = args.frame as? RawVideoFrameBuffer {
                    self.remoteParticipantsEventsAdapter.onVideoFrameRecieved(
                        self.remoteParticipant, videoFrameBuffer.buffer)
                }
            }
        }
}

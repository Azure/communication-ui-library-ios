//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

final class RemoteParticipantsReducerTests: XCTestCase {

    func test_remoteParticipantsReducer_reduce_when_participantListUpdate_then_stateUpdated() {
        let userId = UUID().uuidString
        let infoModel = ParticipantInfoModelBuilder.get(participantIdentifier: userId,
                                                        videoStreamId: "",
                                                        displayName: "",
                                                        isSpeaking: false)
        let action = Action.remoteParticipantsAction(.participantListUpdated(participants: [infoModel]))
        let sut = makeSUT()
        let state = RemoteParticipantsState()
        let result = sut.reduce(state, action)

        XCTAssertEqual(result.participantInfoList.count, 1)
        XCTAssertEqual(result.participantInfoList.first?.userIdentifier, userId)
    }
    func test_remoteParticipantsReducer_reduce_when_dominantSpeakerUpdate_then_stateUpdated() {
        let userId = UUID().uuidString
        let speaker = userId
        let action = Action.remoteParticipantsAction(.dominantSpeakersUpdated(speakers: [speaker]))
        let sut = makeSUT()
        let state = RemoteParticipantsState()
        let result = sut.reduce(state, action)

        XCTAssertEqual(result.dominantSpeakers.count, 1)
        XCTAssertEqual(result.dominantSpeakers.first, userId)
    }
    func test_remoteParticipantsReducer_reduce_when_StatusErrorAndCallReset_then_remoteParticipantStateCleanup() {
        let userId = UUID().uuidString
        let action = Action.errorAction(.statusErrorAndCallReset(internalError: .callJoinFailed,
                                                         error: nil))
        let sut = makeSUT()
        let participant = ParticipantInfoModel(displayName: "displayname",
                                               isSpeaking: false,
                                               isMuted: true,
                                               isRemoteUser: false,
                                               userIdentifier: userId,
                                               status: .idle,
                                               screenShareVideoStreamModel: nil,
                                               cameraVideoStreamModel: nil)
        let remoteParticipantsState = RemoteParticipantsState(participantInfoList: [participant])
        let result = sut.reduce(remoteParticipantsState, action)

        XCTAssertEqual(result.participantInfoList.count, 0)
    }
}

extension RemoteParticipantsReducerTests {
    private func makeSUT() -> Reducer<RemoteParticipantsState, Action> {
        return .liveRemoteParticipantsReducer
    }
}

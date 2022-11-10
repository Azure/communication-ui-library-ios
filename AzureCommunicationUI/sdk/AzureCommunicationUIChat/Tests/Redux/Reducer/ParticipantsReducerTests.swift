//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
@testable import AzureCommunicationUIChat
import AzureCommunicationCommon
import AzureCore
import XCTest

class ParticipantReducerTests: XCTestCase {
    func test_participantReducer_reduce_when_typingIndicatorReceivedAction_then_participantsStateUpdated() {
        let expectedIdentifier = "ID"
        let model = UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier(expectedIdentifier),
                                                  timestamp: Iso8601Date())!
        let state = ParticipantsState()
        let action = Action.participantsAction(.typingIndicatorReceived(participant: model))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        XCTAssertEqual(resultState.typingParticipants.count, 1)
        XCTAssertEqual(resultState.typingParticipants.first?.id, expectedIdentifier)
    }

    func test_participantReducer_reduce_when_participantRemovedAction_then_participantsStateUpdated() {
        let expectedIdentifier = "ID"
        let existingParticipant = UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier(expectedIdentifier),
                                                  timestamp: Iso8601Date())!
        let state = ParticipantsState(typingParticipants: [existingParticipant])
        let participantToBeRemoved = ParticipantInfoModel(identifier: CommunicationUserIdentifier(expectedIdentifier),
                                         displayName: expectedIdentifier)
        let action = Action.participantsAction(.participantsRemoved(participants: [participantToBeRemoved]))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        XCTAssertEqual(resultState.typingParticipants.count, 0)
    }

    func test_participantReducer_reduce_when_newTextMessageReceivedAction_then_participantsStateUpdated() {
        let expectedIdentifier = "ID"
        let existingParticipant = UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier(expectedIdentifier),
                                                  timestamp: Iso8601Date())!
        let state = ParticipantsState(typingParticipants: [existingParticipant])
        let model = ChatMessageInfoModel(type: .text, senderId: expectedIdentifier)
        let action = Action.repositoryAction(.chatMessageReceived(message: model))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        XCTAssertEqual(resultState.typingParticipants.count, 0)
    }

    func test_participantReducer_reduce_when_newHTMLMessageReceivedAction_then_participantsStateUpdated() {
        let expectedIdentifier = "ID"
        let existingParticipant = UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier(expectedIdentifier),
                                                  timestamp: Iso8601Date())!
        let state = ParticipantsState(typingParticipants: [existingParticipant])
        let model = ChatMessageInfoModel(type: .html, senderId: expectedIdentifier)
        let action = Action.repositoryAction(.chatMessageReceived(message: model))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        XCTAssertEqual(resultState.typingParticipants.count, 0)
    }

    func test_participantReducer_reduce_when_newCustomMessageReceivedAction_then_participantsStateUpdated() {
        let expectedIdentifier = "ID"
        let existingParticipant = UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier(expectedIdentifier),
                                                  timestamp: Iso8601Date())!
        let state = ParticipantsState(typingParticipants: [existingParticipant])
        let model = ChatMessageInfoModel(type: .custom(""), senderId: expectedIdentifier)
        let action = Action.repositoryAction(.chatMessageReceived(message: model))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        XCTAssertEqual(resultState.typingParticipants.count, 0)
    }
}

extension ParticipantReducerTests {
    func getSUT() -> Reducer<ParticipantsState, Action> {
        return .liveParticipantsReducer
    }
}

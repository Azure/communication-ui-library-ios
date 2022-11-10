//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
@testable import AzureCommunicationUIChat
import AzureCommunicationCommon
import AzureCore
import XCTest

class ParticipantReducerTests: XCTestCase {
    func test_participantsReducer_reduce_when_fetchListOfParticipantsSuccessParticipantAction_then_stateUpdated() {
        let participants = [
            ParticipantInfoModel(identifier: CommunicationUserIdentifier("id1"),
                                 displayName: "displayName1"),
            ParticipantInfoModel(identifier: CommunicationUserIdentifier("id2"),
                                 displayName: "displayName2")
        ]
        let initialTimestamp = Date()
        let state = ParticipantsState(
            participantsUpdatedTimestamp: initialTimestamp)
        let action = Action.participantsAction(
            .fetchListOfParticipantsSuccess(participants: participants))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.participantsUpdatedTimestamp > initialTimestamp)
        XCTAssertEqual(resultState.participants.count, 2)

        XCTAssertTrue(resultState.typingIndicatorUpdatedTimestamp > initialTimestamp)
        XCTAssertEqual(resultState.typingIndicatorMap.count, 0)
    }

    func test_participantsReducer_reduce_when_participantsAddedParticipantAction_then_stateUpdated() {
        let initialParticipantsMap = [
            "id1": ParticipantInfoModel(identifier: CommunicationUserIdentifier("id1"),
                                        displayName: "displayName1"),
            "id2": ParticipantInfoModel(identifier: CommunicationUserIdentifier("id2"),
                                        displayName: "displayName2")
        ]
        let newParticipants = [
            ParticipantInfoModel(identifier: CommunicationUserIdentifier("id3"),
                                 displayName: "displayName3"),
            ParticipantInfoModel(identifier: CommunicationUserIdentifier("id4"),
                                 displayName: "displayName4")
        ]
        let initialTimestamp = Date()
        let state = ParticipantsState(
            participants: initialParticipantsMap,
            participantsUpdatedTimestamp: initialTimestamp)
        let action = Action.participantsAction(
            .participantsAdded(participants: newParticipants))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.participantsUpdatedTimestamp > initialTimestamp)
        XCTAssertEqual(resultState.participants.count, 4)
    }

    func test_participantsReducer_reduce_when_participantsRemovedParticipantAction_then_stateUpdated() {
        let initialParticipantsMap = [
            "id1": ParticipantInfoModel(identifier: CommunicationUserIdentifier("id1"),
                                        displayName: "displayName1"),
            "id2": ParticipantInfoModel(identifier: CommunicationUserIdentifier("id2"),
                                        displayName: "displayName2"),
            "id3": ParticipantInfoModel(identifier: CommunicationUserIdentifier("id3"),
                                        displayName: "displayName3")
        ]
        let initialTypingIndicatorMap = [
            "id1": Date(),
            "id2": Date()
        ]
        let removedParticipants = [
            ParticipantInfoModel(identifier: CommunicationUserIdentifier("id2"),
                                 displayName: "displayName2"),
            ParticipantInfoModel(identifier: CommunicationUserIdentifier("id3"),
                                 displayName: "anotherName3")
        ]
        let initialTimestamp = Date()
        let state = ParticipantsState(
            participants: initialParticipantsMap,
            participantsUpdatedTimestamp: initialTimestamp,
            typingIndicatorMap: initialTypingIndicatorMap,
        typingIndicatorUpdatedTimestamp: initialTimestamp)
        let action = Action.participantsAction(
            .participantsRemoved(participants: removedParticipants))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.participantsUpdatedTimestamp > initialTimestamp)
        XCTAssertEqual(resultState.participants.count, 1)
        XCTAssertTrue(resultState.typingIndicatorUpdatedTimestamp > initialTimestamp)
        XCTAssertEqual(resultState.typingIndicatorMap.count, 1)
    }

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

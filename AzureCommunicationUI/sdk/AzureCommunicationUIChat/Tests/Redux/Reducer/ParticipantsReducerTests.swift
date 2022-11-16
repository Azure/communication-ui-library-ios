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
            .fetchListOfParticipantsSuccess(participants: participants, localParticipantId: "localParticipantId"))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.participantsUpdatedTimestamp > initialTimestamp)
        XCTAssertEqual(resultState.participants.count, 2)
        XCTAssertEqual(resultState.typingParticipants.count, 0)
        // Uncomment after mask admin user is done
//        XCTAssertEqual(resultState.readReceiptMap.count, 2)
//        XCTAssertEqual(resultState.readReceiptMap["id2"], .distantPast)
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
        let readReceiptMap: [String: Date] = ["id1": .distantPast, "id2": .distantPast]
        let state = ParticipantsState(
            participants: initialParticipantsMap,
            participantsUpdatedTimestamp: initialTimestamp,
            readReceiptMap: readReceiptMap)
        let action = Action.participantsAction(
            .participantsAdded(participants: newParticipants))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.participantsUpdatedTimestamp > initialTimestamp)
        XCTAssertEqual(resultState.participants.count, 4)
        XCTAssertEqual(resultState.readReceiptMap["id3"], .distantPast)
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
        let initialTypingParticipants: [UserEventTimestampModel] = [
            UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier("id1"),
                                    timestamp: Iso8601Date())!,
            UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier("id2"),
                                    timestamp: Iso8601Date())!
        ]
        let removedParticipants = [
            ParticipantInfoModel(identifier: CommunicationUserIdentifier("id2"),
                                 displayName: "displayName2"),
            ParticipantInfoModel(identifier: CommunicationUserIdentifier("id3"),
                                 displayName: "anotherName3")
        ]
        let initialTimestamp = Date()
        let readReceiptMap: [String: Date] = ["id1": .distantPast, "id2": .distantPast, "id3": .distantPast]
        let state = ParticipantsState(
            participants: initialParticipantsMap,
            participantsUpdatedTimestamp: initialTimestamp,
            typingParticipants: initialTypingParticipants,
            readReceiptMap: readReceiptMap)
        let action = Action.participantsAction(
            .participantsRemoved(participants: removedParticipants))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertTrue(resultState.participantsUpdatedTimestamp > initialTimestamp)
        XCTAssertEqual(resultState.participants.count, 1)
        XCTAssertEqual(resultState.typingParticipants.count, 1)
        XCTAssertEqual(resultState.readReceiptMap.count, 1)
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
        let initialParticipantsMap = [
            expectedIdentifier: ParticipantInfoModel(identifier: CommunicationUserIdentifier(expectedIdentifier),
                                        displayName: "displayName1")
        ]
        let existingParticipant = UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier(expectedIdentifier),
                                                  timestamp: Iso8601Date())!
        let state = ParticipantsState(participants: initialParticipantsMap,
                                      typingParticipants: [existingParticipant])
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

    func test_participantReducer_reduce_when_readReceiptReceivedAction_then_participantsStateUpdated() {
        let participantId = "participantId"
        let messageId = "1668456344995"
        let state = ParticipantsState()
        let readReceiptInfo = ReadReceiptInfoModel(senderIdentifier: CommunicationUserIdentifier(participantId), chatMessageId: messageId, readOn: Iso8601Date())
        let action = Action.participantsAction(.readReceiptReceived(readReceiptInfo: readReceiptInfo))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        XCTAssertEqual(resultState.readReceiptMap.count, 1)
        XCTAssertEqual(resultState.readReceiptMap[participantId], messageId.convertEpochStringToTimestamp())
        XCTAssertEqual(resultState.readReceiptUpdatedTimestamp, messageId.convertEpochStringToTimestamp())
    }
}

extension ParticipantReducerTests {
    func getSUT() -> Reducer<ParticipantsState, Action> {
        return .liveParticipantsReducer
    }
}

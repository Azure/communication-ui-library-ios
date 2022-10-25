//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
@testable import AzureCommunicationUIChat
import AzureCommunicationCommon
import XCTest

class ParticipantReducerTests: XCTestCase {
    func test_participantReducer_reduce_when_typingIndicatorReceivedAction_then_participantsStateUpdated() {
        let expectedIdentifier = "ID"
        let timer = Timer(timeInterval: 1, repeats: false, block: {_ in })
        let state = ParticipantsState()
        let action = Action.participantsAction(.typingIndicatorReceived(id: expectedIdentifier, timer: timer))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        XCTAssertEqual(resultState.typingIndicatorMap.count, 1)
        XCTAssertEqual(resultState.typingIndicatorMap.first?.key, expectedIdentifier)
    }

    func test_participantReducer_reduce_when_participantRemovedAction_then_participantsStateUpdated() {
        let expectedIdentifier = "ID"
        let timer = Timer(timeInterval: 1, repeats: false, block: {_ in })
        let state = ParticipantsState(typingIndicatorMap: [
            expectedIdentifier: timer
        ])
        let model = ParticipantInfoModel(identifier: CommunicationUserIdentifier(expectedIdentifier),
                                         displayName: expectedIdentifier)
        let action = Action.participantsAction(.participantsRemoved(participants: [model]))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)
        XCTAssertEqual(resultState.typingIndicatorMap.count, 0)
    }

    func test_participantReducer_reduce_when_newTextMessageReceivedAction_then_participantsStateUpdated() {
        let expectation = XCTestExpectation(description: "Clearing Indicator when text message received")
        let expectedIdentifier = "ID"
        let timer = Timer(timeInterval: 1, repeats: false, block: {_ in
            expectation.fulfill()
        })
        let state = ParticipantsState(typingIndicatorMap: [
            expectedIdentifier: timer
        ])
        let model = ChatMessageInfoModel(type: .text, senderId: expectedIdentifier)
        let action = Action.repositoryAction(.chatMessageReceived(message: model))
        let sut = getSUT()
        _ = sut.reduce(state, action)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantReducer_reduce_when_newHTMLMessageReceivedAction_then_participantsStateUpdated() {
        let expectation = XCTestExpectation(description: "Clearing Indicator when HTML message received")
        let expectedIdentifier = "ID"
        let timer = Timer(timeInterval: 1, repeats: false, block: {_ in
            expectation.fulfill()
        })
        let state = ParticipantsState(typingIndicatorMap: [
            expectedIdentifier: timer
        ])
        let model = ChatMessageInfoModel(type: .html, senderId: expectedIdentifier)
        let action = Action.repositoryAction(.chatMessageReceived(message: model))
        let sut = getSUT()
        _ = sut.reduce(state, action)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantReducer_reduce_when_newCustomMessageReceivedAction_then_participantsStateUpdated() {
        let expectation = XCTestExpectation(description: "Clearing Indicator when custom message received")
        let expectedIdentifier = "ID"
        let timer = Timer(timeInterval: 1, repeats: false, block: {_ in
            expectation.fulfill()
        })
        let state = ParticipantsState(typingIndicatorMap: [
            expectedIdentifier: timer
        ])
        let model = ChatMessageInfoModel(type: .custom("message"), senderId: expectedIdentifier)
        let action = Action.repositoryAction(.chatMessageReceived(message: model))
        let sut = getSUT()
        _ = sut.reduce(state, action)
        wait(for: [expectation], timeout: 1)
    }
}

extension ParticipantReducerTests {
    func getSUT() -> Reducer<ParticipantsState, Action> {
        return .liveParticipantsReducer
    }
}

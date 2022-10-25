//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class ChatReducerTests: XCTestCase {

    func test_chatReducer_reduce_when_topicRetrievedChatAction_then_stateUpdated() {
        let expectedTopic = "newTopic"
        let state = ChatState()
        let action = Action.chatAction(.topicRetrieved(topic: expectedTopic))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.topic, expectedTopic)
    }

    func test_chatReducer_reduce_when_chatTopicUpdatedChatAction_then_stateUpdated() {
        let expectedTopic = "newTopic"
        let threadInfo = ChatThreadInfoModel(topic: expectedTopic,
                                             receivedOn: Iso8601Date())
        let state = ChatState()
        let action = Action.chatAction(.chatTopicUpdated(threadInfo: threadInfo))
        let sut = getSUT()
        let resultState = sut.reduce(state, action)

        XCTAssertEqual(resultState.topic, expectedTopic)
    }
}

extension ChatReducerTests {
    private func getSUT() -> Reducer<ChatState, Action> {
        return .liveChatReducer
    }
}

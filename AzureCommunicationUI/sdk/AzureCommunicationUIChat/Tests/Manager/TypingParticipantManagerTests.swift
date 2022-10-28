//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUIChat
import AzureCore
import AzureCommunicationCommon

class TypingParticipantsManagerTests: XCTestCase {
    var mockStoreFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var typingIndicatorManager: TypingParticipantsManager!

    override func setUp() {
        super.setUp()
        mockStoreFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        typingIndicatorManager = TypingParticipantsManager(store: mockStoreFactory.store)
        TypingParticipantsManager.Constants.timeout = 0
        TypingParticipantsManager.Constants.checkInterval = 0
    }

    override func tearDown() {
        super.tearDown()
        cancellable = nil
        typingIndicatorManager = nil
        mockStoreFactory = nil
    }

    func test_typingIndicatorManager_receiveState_when_noTypingParticipantGiven_then_noSetTypingIndicatorDispatched() {
        let newState = getAppState()
        mockStoreFactory.setState(newState)
        XCTAssertFalse(mockStoreFactory.didRecordAction)
    }

    func test_typingIndicatorManager_receiveState_when_oneTypingParticipantGiven_then_SetTypingIndicatorDispatched() {
        let newState = getAppState(participantState: ParticipantsState(typingParticipants: [
            UserEventTimestampModel(userIdentifier: CommunicationUserIdentifier(""), timestamp: Iso8601Date())!
        ]))
        mockStoreFactory.setState(newState)
        let actionExpectation = XCTestExpectation(description: "Dispatch Set Typing Indicator Action")
        mockStoreFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                guard let self = self else {
                    XCTFail("self is nil")
                    return
                }
                switch self.mockStoreFactory.firstAction {
                case .participantsAction(.setTypingIndicator(_)):
                    actionExpectation.fulfill()
                default:
                    XCTFail("unknown action dispatched")
                }
            }.store(in: cancellable)
        wait(for: [actionExpectation], timeout: 1)
    }
}

extension TypingParticipantsManagerTests {
    func getAppState(participantState: ParticipantsState = ParticipantsState()) -> AppState {
        return AppState(lifeCycleState: LifeCycleState(),
                        chatState: ChatState(),
                        participantsState: participantState,
                        navigationState: NavigationState(),
                        repositoryState: RepositoryState(),
                        errorState: .init())
    }
}

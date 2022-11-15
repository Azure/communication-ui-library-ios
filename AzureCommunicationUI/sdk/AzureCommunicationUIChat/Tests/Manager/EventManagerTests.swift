//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class EventManagerTests: XCTestCase {
    var mockStoreFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var eventManager: EventManager!

    var handlerChatExpectation: XCTestExpectation!
    var expectedError: ChatCompositeError?

    override func setUp() {
        super.setUp()
        handlerChatExpectation = XCTestExpectation(description: "Delegate expectation")
        mockStoreFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        eventManager = EventManager(store: mockStoreFactory.store,
                                    chatCompositeEventsHandler: ChatComposite.Events())
    }

    override func tearDown() {
        super.tearDown()
        handlerChatExpectation = nil
        mockStoreFactory = nil
        cancellable = nil
        eventManager = nil
        expectedError = nil
    }

    func test_eventManager_receiveState_when_localParticipantRemoved_then_onLocalParticipantRemovedCalled() {
        let handler = ChatComposite.Events()
        handler.onLocalUserRemoved = { [weak self] in
            guard let self = self else {
                return
            }
            self.handlerChatExpectation.fulfill()
        }
        eventManager = EventManager(store: mockStoreFactory.store,
                                    chatCompositeEventsHandler: handler)
        let newState = getAppState(participantState:
                                    ParticipantsState(localParticipantStatus: .removed))
        mockStoreFactory.setState(newState)
        wait(for: [handlerChatExpectation], timeout: 1)
    }

    func test_eventManager_receiveState_when_localParticipantJoined_then_onLocalParticipantRemovedNotCalled() {
        handlerChatExpectation.isInverted = true
        let handler = ChatComposite.Events()
        handler.onLocalUserRemoved = { [weak self] in
            guard let self = self else {
                return
            }
            self.handlerChatExpectation.fulfill()
        }
        eventManager = EventManager(store: mockStoreFactory.store,
                                    chatCompositeEventsHandler: handler)
        let newState = getAppState(participantState:
                                    ParticipantsState(localParticipantStatus: .joined))
        mockStoreFactory.setState(newState)
        wait(for: [handlerChatExpectation], timeout: 1)
    }

}

extension EventManagerTests {
    func getAppState(naviState: NavigationState = NavigationState(status: .inChat)) -> AppState {
        return AppState(lifeCycleState: LifeCycleState(),
                        chatState: ChatState(),
                        participantsState: ParticipantsState(),
                        navigationState: naviState,
                        repositoryState: RepositoryState(),
                        errorState: .init())
    }

    func getAppState(errorState: ErrorState) -> AppState {
        return AppState(lifeCycleState: LifeCycleState(),
                        chatState: ChatState(),
                        participantsState: ParticipantsState(),
                        navigationState: NavigationState(status: .inChat),
                        repositoryState: RepositoryState(),
                        errorState: errorState)
    }

    func getAppState(participantState: ParticipantsState) -> AppState {
        return AppState(lifeCycleState: LifeCycleState(),
                        chatState: ChatState(),
                        participantsState: participantState,
                        navigationState: NavigationState(status: .inChat),
                        repositoryState: RepositoryState(),
                        errorState: ErrorState())
    }
}

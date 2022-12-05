//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUIChat

class ErrorManagerTests: XCTestCase {
    var mockStoreFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var errorManager: ErrorManager!

    var handlerChatExpectation: XCTestExpectation!
    var expectedError: ChatCompositeError?

    override func setUp() {
        super.setUp()
        handlerChatExpectation = XCTestExpectation(description: "Delegate expectation")
        mockStoreFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        errorManager = ErrorManager(store: mockStoreFactory.store,
                                    chatCompositeEventsHandler: getEventsHandler())
    }

    override func tearDown() {
        super.tearDown()
        handlerChatExpectation = nil
        mockStoreFactory = nil
        cancellable = nil
        errorManager = nil
        expectedError = nil
    }

    func test_errorManager_receiveState_when_noFatalError_navigationExit_then_noDidFailEventCalled_hostingVCDismissCalled() {
        handlerChatExpectation.isInverted = true
        let newState = getAppState(naviState: NavigationState(status: .exit))
        mockStoreFactory.setState(newState)

        wait(for: [handlerChatExpectation], timeout: 1)
    }

    func test_errorManager_receiveState_when_noFatalError_chatNotExisted_then_nodidFailEventCalled_hostingVCDismissCalled() {
        handlerChatExpectation.isInverted = true
        let newState = getAppState(naviState: NavigationState(status: .inChat))
        mockStoreFactory.setState(newState)

        wait(for: [handlerChatExpectation], timeout: 1)
    }

    func test_errorManager_receiveState_when_nonFatalErrorSendMessage_then_receiveDidFail() {
        let nonFatalError = ChatCompositeError(code: ChatCompositeErrorCode.messageSendFailed, error: nil)
        self.expectedError = nonFatalError
        let errorState = ErrorState(internalError: .messageSendFailed,
                                    error: nil,
                                    errorCategory: .chatState)
        let newState = getAppState(errorState: errorState)

        mockStoreFactory.setState(newState)
        wait(for: [handlerChatExpectation], timeout: 1)
    }

    func test_errorManager_receiveState_when_fatalErrorChatConnect_then_receiveDidFail() {
        let fatalError = ChatCompositeError(code: ChatCompositeErrorCode.connectFailed, error: nil)
        self.expectedError = fatalError
        let errorState = ErrorState(internalError: .connectFailed,
                                    error: nil,
                                    errorCategory: .chatState)
        let newState = getAppState(errorState: errorState)

        mockStoreFactory.setState(newState)
        wait(for: [handlerChatExpectation], timeout: 1)
    }

    func test_errorManager_receiveState_when_fatalErrorTokenExpired_then_receiveEmergencyExitAction() {
        let fatalError = ChatCompositeError(
            code: ChatCompositeErrorCode.connectFailed,
            error: nil)

        self.expectedError = fatalError
        let errorState = ErrorState(internalError: .connectFailed,
                                    error: nil,
                                    errorCategory: .fatal)
        let newState = getAppState(errorState: errorState)
        let actionExpectation = XCTestExpectation(description: "Dispatch the new emergency exit action")

        mockStoreFactory.setState(newState)
        mockStoreFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in
                guard let self = self else {
                    XCTFail("self is nil")
                    return
                }
                XCTAssertTrue(self.mockStoreFactory.actions.first == Action.compositeExitAction)
                actionExpectation.fulfill()
            }.store(in: cancellable)

        wait(for: [handlerChatExpectation, actionExpectation], timeout: 1)
    }
}

extension ErrorManagerTests {
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

    func getEventsHandler() -> ChatUIClient.Events {
        let handler = ChatUIClient.Events()
        handler.onError = { [weak self] chatCompositeError in
            guard let self = self else {
                return
            }

            XCTAssertEqual(chatCompositeError.code, self.expectedError?.code)
            self.handlerChatExpectation.fulfill()

        }
        return handler
    }
}

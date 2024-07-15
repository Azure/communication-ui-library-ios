//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import Combine
@testable import AzureCommunicationUICalling

class ParticipantsListViewModelTests: XCTestCase {
    private var cancellable: CancelBag!
    private var localizationProvider: LocalizationProviderMocking!
    private var storeFactory: StoreFactoryMocking!
    private var logger: LoggerMocking!
    private var factoryMocking: CompositeViewModelFactoryMocking!

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
        localizationProvider = LocalizationProviderMocking()
        storeFactory = StoreFactoryMocking()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store,
                                                          avatarManager: AvatarViewManagerMocking(
                                                            store: storeFactory.store,
                                                            localParticipantViewData: nil))
    }

    func test_update_withLocalUserMicOn_shouldUpdateMeetingParticipants() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish a View Model for the local participant with mic on")

        let audioStateOn = LocalUserState.AudioState(operation: .on, device: .receiverSelected)
        let localUserStateOn = LocalUserState(audioState: audioStateOn)
        let remoteParticipantsState = RemoteParticipantsState(participantInfoList: [], lastUpdateTimeStamp: Date())

        sut.$meetingParticipants
            .dropFirst()
            .sink { participants in
                XCTAssertEqual(participants.count, 1)
                if let firstParticipant = participants.first as? ParticipantsListCellViewModel {
                    XCTAssertFalse(firstParticipant.isMuted)
                } else {
                    XCTFail("Expected participant to be of type ParticipantsListCellViewModel")
                }
                expectation.fulfill()
            }
            .store(in: cancellable)

        sut.update(localUserState: localUserStateOn, remoteParticipantsState: remoteParticipantsState, isDisplayed: true)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_update_withLocalUserMicOff_shouldUpdateMeetingParticipants() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish a View Model for the local participant with mic off")

        let audioStateOff = LocalUserState.AudioState(operation: .off, device: .receiverSelected)
        let localUserStateOff = LocalUserState(audioState: audioStateOff)
        let remoteParticipantsState = RemoteParticipantsState(participantInfoList: [], lastUpdateTimeStamp: Date())

        sut.$meetingParticipants
            .dropFirst()
            .sink { participants in
                XCTAssertEqual(participants.count, 1)
                if let firstParticipant = participants.first as? ParticipantsListCellViewModel {
                    XCTAssertTrue(firstParticipant.isMuted)
                } else {
                    XCTFail("Expected participant to be of type ParticipantsListCellViewModel")
                }
                expectation.fulfill()
            }
            .store(in: cancellable)

        sut.update(localUserState: localUserStateOff, remoteParticipantsState: remoteParticipantsState, isDisplayed: true)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_update_withRemoteParticipants_shouldUpdateMeetingParticipants() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish View Models for the remote participants")

        let audioStateOn = LocalUserState.AudioState(operation: .on, device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioStateOn)
        let remoteParticipant = ParticipantInfoModel(
            displayName: "John Doe",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: false,
            userIdentifier: "123",
            status: .connected,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)

        let remoteParticipantsState = RemoteParticipantsState(participantInfoList: [remoteParticipant], lastUpdateTimeStamp: Date())

        sut.$meetingParticipants
            .dropFirst()
            .sink { participants in
                XCTAssertEqual(participants.count, 2)
                if let firstParticipant = participants.first as? ParticipantsListCellViewModel {
                    XCTAssertFalse(firstParticipant.isMuted)
                } else {
                    XCTFail("Expected participant to be of type ParticipantsListCellViewModel")
                }
                if let secondParticipant = participants.last as? ParticipantsListCellViewModel {
                    XCTAssertEqual(secondParticipant.participantId, "123")
                    XCTAssertFalse(secondParticipant.isMuted)
                } else {
                    XCTFail("Expected participant to be of type ParticipantsListCellViewModel")
                }
                expectation.fulfill()
            }
            .store(in: cancellable)

        sut.update(localUserState: localUserState, remoteParticipantsState: remoteParticipantsState, isDisplayed: true)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_update_withLobbyParticipants_shouldUpdateLobbyParticipants() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish View Models for the lobby participants")

        let audioStateOn = LocalUserState.AudioState(operation: .on, device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioStateOn, participantRole: .organizer)
        let lobbyParticipant = ParticipantInfoModel(
            displayName: "John Doe",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "123",
            status: .inLobby,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)

        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: [lobbyParticipant],
            lastUpdateTimeStamp: Date())

        sut.$lobbyParticipants
            .dropFirst()
            .sink { participants in
                XCTAssertEqual(participants.count, 1)
                if let firstParticipant = participants.first as? ParticipantsListCellViewModel {
                    XCTAssertEqual(firstParticipant.participantId, "123")
                } else {
                    XCTFail("Expected participant to be of type ParticipantsListCellViewModel")
                }
                expectation.fulfill()
            }
            .store(in: cancellable)

        sut.update(localUserState: localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   isDisplayed: true)
        wait(for: [expectation], timeout: 1.0)
    }

//    func test_update_withRoleChange_shouldUpdateParticipants() {
//        let sut = makeSUT()
//        let expectation = XCTestExpectation(description: "Should publish updated View Models when the role changes")
//
//        let audioStateOn = LocalUserState.AudioState(operation: .on, device: .receiverSelected)
//        let localUserState = LocalUserState(audioState: audioStateOn, participantRole: .presenter)
//        let remoteParticipantsState = RemoteParticipantsState(participantInfoList: [], lastUpdateTimeStamp: Date())
//
//        sut.$meetingParticipants
//            .dropFirst()
//            .sink { participants in
//                XCTAssertEqual(participants.count, 1)
//                if let firstParticipant = participants.first as? ParticipantsListCellViewModel {
//                    XCTAssertFalse(firstParticipant.isMuted)
//                } else {
//                    XCTFail("Expected participant to be of type ParticipantsListCellViewModel")
//                }
//                expectation.fulfill()
//            }
//            .store(in: &cancellable)
//
//        sut.update(localUserState: localUserState, remoteParticipantsState: remoteParticipantsState, isDisplayed: true)
//        wait(for: [expectation], timeout: 1.0)
//    }
//
//    func test_admitAll_shouldDispatchAdmitAllAction() {
//        let sut = makeSUT()
//        let expectation = XCTestExpectation(description: "Should dispatch admitAll action")
//
//        var actionDispatched: Action?
//        let dispatchAction: ActionDispatch = { action in
//            actionDispatched = action
//            expectation.fulfill()
//        }
//
//        sut.dispatch = dispatchAction
//        sut.admitAll()
//
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(actionDispatched, .remoteParticipantsAction(.admitAll))
//    }
//
//    func test_declineAll_shouldDispatchDeclineAllAction() {
//        let sut = makeSUT()
//        let expectation = XCTestExpectation(description: "Should dispatch declineAll action")
//
//        var actionDispatched: Action?
//        let dispatchAction: ActionDispatch = { action in
//            actionDispatched = action
//            expectation.fulfill()
//        }
//
//        sut.dispatch = dispatchAction
//        sut.declineAll()
//
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(actionDispatched, .remoteParticipantsAction(.declineAll))
//    }
//
//    func test_admitParticipant_shouldDispatchAdmitParticipantAction() {
//        let sut = makeSUT()
//        let expectation = XCTestExpectation(description: "Should dispatch admit participant action")
//
//        var actionDispatched: Action?
//        let dispatchAction: ActionDispatch = { action in
//            actionDispatched = action
//            expectation.fulfill()
//        }
//
//        sut.dispatch = dispatchAction
//        sut.admitParticipant("123")
//
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(actionDispatched, .remoteParticipantsAction(.admit(participantId: "123")))
//    }
//
//    func test_declineParticipant_shouldDispatchDeclineParticipantAction() {
//        let sut = makeSUT()
//        let expectation = XCTestExpectation(description: "Should dispatch decline participant action")
//
//        var actionDispatched: Action?
//        let dispatchAction: ActionDispatch = { action in
//            actionDispatched = action
//            expectation.fulfill()
//        }
//
//        sut.dispatch = dispatchAction
//        sut.declineParticipant("123")
//
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(actionDispatched, .remoteParticipantsAction(.decline(participantId: "123")))
//    }
}

// Mock implementations for dependencies
extension ParticipantsListViewModelTests {
    func makeSUT() -> ParticipantsListViewModel {
        return ParticipantsListViewModel(compositeViewModelFactory: factoryMocking,
                                         localUserState: LocalUserState(),
                                         dispatchAction: storeFactory.store.dispatch,
                                         localizationProvider: localizationProvider,
                                         onUserClicked: { _ in },
                                         avatarManager: AvatarViewManagerMocking(store: storeFactory.store, localParticipantViewData: nil))
    }
}

//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
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
                                                            localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                                                            localParticipantViewData: nil),
                                                          updatableOptionsManager: UpdatableOptionsManager(store: storeFactory.store, setupScreenOptions: nil, callScreenOptions: nil))
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

    func test_update_withRemoteParticipants_shouldStaySorted() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish View Models for the remote participants")

        let audioStateOn = LocalUserState.AudioState(operation: .on, device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioStateOn, displayName: "DEF")
        let remoteParticipant1 = ParticipantInfoModel(
            displayName: "ABC",
            isSpeaking: false,
            isTypingRtt: false,
            isMuted: false,
            isRemoteUser: false,
            userIdentifier: "123",
            status: .connected,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)

        let remoteParticipant2 = ParticipantInfoModel(
            displayName: "GHI",
            isSpeaking: false,
            isTypingRtt: false,
            isMuted: false,
            isRemoteUser: false,
            userIdentifier: "323",
            status: .connected,
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)

        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: [
                remoteParticipant1,
                remoteParticipant2
            ],
            lastUpdateTimeStamp: Date())

        sut.$meetingParticipants
            .dropFirst(1)
            .sink { participants in
                XCTAssertEqual(participants.count, 3)
                if let first = participants[0] as? ParticipantsListCellViewModel,
                   let second = participants[1] as? ParticipantsListCellViewModel,
                   let third = participants[2] as? ParticipantsListCellViewModel {
                    XCTAssertEqual("ABC", first.getParticipantName(with: nil))
                    XCTAssertEqual("DEF", second.getParticipantName(with: nil))
                    XCTAssertEqual("GHI", third.getParticipantName(with: nil))
                } else {
                    XCTFail("Expected participant to be of type ParticipantsListCellViewModel")
                }

                expectation.fulfill()
            }
            .store(in: cancellable)

        sut.update(localUserState: localUserState, remoteParticipantsState: remoteParticipantsState, isDisplayed: true)
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
            isTypingRtt: false,
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

    func test_update_withLobbyParticipants_shouldUpdateLobbyParticipants_WhenOrganizer() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish View Models for the lobby participants")

        let audioStateOn = LocalUserState.AudioState(operation: .on, device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioStateOn, participantRole: .organizer)
        let lobbyParticipant = ParticipantInfoModel(
            displayName: "John Doe",
            isSpeaking: false,
            isTypingRtt: false,
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

    func test_update_withLobbyParticipants_shouldNotUpdateLobbyParticipants_WhenAttendee() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish View Models for the lobby participants")

        let audioStateOn = LocalUserState.AudioState(operation: .on, device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioStateOn, participantRole: .attendee)
        let lobbyParticipant = ParticipantInfoModel(
            displayName: "John Doe",
            isSpeaking: false,
            isTypingRtt: false,
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
                XCTAssertEqual(participants.count, 0)
                expectation.fulfill()
            }
            .store(in: cancellable)

        sut.update(localUserState: localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   isDisplayed: true)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_admitAll_shouldDispatchAdmitAllAction() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should dispatch admitAll action")
        sut.admitAll()
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .remoteParticipantsAction(.admitAll))
                expectation.fulfill()
            }.store(in: cancellable)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_declineAll_shouldDispatchDeclineAllAction() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should dispatch declineAll action")
        sut.declineAll()
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .remoteParticipantsAction(.declineAll))
                expectation.fulfill()
            }.store(in: cancellable)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_admitParticipant_shouldDispatchAdmitParticipantAction() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should dispatch admitAll action")
        sut.admitParticipant("test")
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .remoteParticipantsAction(.admit(participantId: "test")))
                expectation.fulfill()
            }.store(in: cancellable)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_declineParticipant_shouldDispatchDeclineParticipantAction() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should dispatch admitAll action")
        sut.declineParticipant("test")
        storeFactory.store.$state
            .dropFirst(1)
            .sink { [weak self] _ in  XCTAssertEqual(self?.storeFactory.actions.count, 1)
                XCTAssertTrue(self?.storeFactory.actions.first == .remoteParticipantsAction(.decline(participantId: "test")))
                expectation.fulfill()
            }.store(in: cancellable)
        wait(for: [expectation], timeout: 1.0)
    }

    // More tests to add eventually
    // 1) If regular participant row clicked, dispatch show participant details
    // 2) If own user tapped, no dispatch to show details/menu
    // 3) On Lobby Participant View model, can admit
    // 4) + More label
    // 5) Verify header and counts for lobby and regular
}

// Mock implementations for dependencies
extension ParticipantsListViewModelTests {
    func makeSUT() -> ParticipantsListViewModel {
        return ParticipantsListViewModel(compositeViewModelFactory: factoryMocking,
                                         localUserState: LocalUserState(),
                                         dispatchAction: storeFactory.store.dispatch,
                                         localizationProvider: localizationProvider,
                                         onUserClicked: { _ in },
                                         avatarManager: AvatarViewManagerMocking(store: storeFactory.store,
                                                                                 localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                                                                                 localParticipantViewData: nil))
    }
}

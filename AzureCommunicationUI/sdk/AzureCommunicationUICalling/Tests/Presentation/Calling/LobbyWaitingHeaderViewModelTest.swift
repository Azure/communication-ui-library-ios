//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class LobbyWaitingHeaderViewModelTests: XCTestCase {

    typealias ParticipantsListViewModelUpdateStates = (LocalUserState, RemoteParticipantsState) -> Void
    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var localizationProvider: LocalizationProviderMocking!
    var logger: LoggerMocking!
    var factoryMocking: CompositeViewModelFactoryMocking!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        localizationProvider = LocalizationProviderMocking()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(logger: logger, store: storeFactory.store)
    }

    override func tearDown() {
        super.tearDown()
        storeFactory = nil
        cancellable = nil
        localizationProvider = nil
        logger = nil
        factoryMocking = nil
    }

    func test_infoHeaderViewModel_update_when_participantInfoListEmpty_then_shouldNotBeDisplayed() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should not display")
        expectation.isInverted = true
        sut.$isDisplayed
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("If no inLobby participants then should not display")
            }).store(in: cancellable)

        let participantInfoModel: [ParticipantInfoModel] = []
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertFalse(sut.isDisplayed)
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_update_when_participantInfoListHasNoLobbyParticipants_then_shouldNotBeDisplayed() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should not display")
        expectation.isInverted = true
        sut.$isDisplayed
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("If no inLobby participants then should not display")
            }).store(in: cancellable)

        let participantInfoModel: [ParticipantInfoModel] =
            makeParticipants([.connected, .connecting, .disconnected, .earlyMedia, .hold, .idle, .ringing])
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertFalse(sut.isDisplayed)
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_update_when_lobbyParticipantIsRemoved_then_shouldNotBeDisplayed() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should not display")
        sut.$isDisplayed
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
            }).store(in: cancellable)

        var participantInfoModel: [ParticipantInfoModel] =
            makeParticipants([.connected, .connecting, .disconnected, .earlyMedia, .hold, .idle, .ringing, .inLobby])
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        let localUserState = LocalUserState(participantRole: .presenter)

        sut.update(localUserState: localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertTrue(sut.isDisplayed)
        wait(for: [expectation], timeout: 1)

        let updatedParticipantInfoModel: [ParticipantInfoModel] =
            makeParticipants([.connected, .connecting, .disconnected, .earlyMedia, .hold, .idle, .ringing])
        let updatedRemoteParticipantsState = RemoteParticipantsState(
            participantInfoList: updatedParticipantInfoModel, lastUpdateTimeStamp: Date())

        sut.update(localUserState: storeFactory.store.state.localUserState,
                   remoteParticipantsState: updatedRemoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertFalse(sut.isDisplayed)
    }

    func test_infoHeaderViewModel_update_when_participantInfoListHasLobbyParticipants_then_shouldBeDisplayed() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should display")
        sut.$isDisplayed
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
            }).store(in: cancellable)

        let participantInfoModel: [ParticipantInfoModel] = makeParticipants([.inLobby])
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        sut.update(localUserState: LocalUserState(participantRole: .presenter),
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertTrue(sut.isDisplayed)
        wait(for: [expectation], timeout: 1)

        sut.update(localUserState: LocalUserState(participantRole: .organizer),
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertTrue(sut.isDisplayed)

        sut.update(localUserState: LocalUserState(participantRole: .coOrganizer),
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertTrue(sut.isDisplayed)

    }

    func test_infoHeaderViewModel_update_when_participantInfoListHasLobbyParticipantsButHasNoPermissionToAdmit_then_shouldNotBeDisplayed() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should not display")
        expectation.isInverted = true
        sut.$isDisplayed
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
            }).store(in: cancellable)

        let participantInfoModel: [ParticipantInfoModel] = makeParticipants([.inLobby])
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        let localUserState = LocalUserState(participantRole: .consumer)
        sut.update(localUserState: localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertFalse(sut.isDisplayed)
        wait(for: [expectation], timeout: 1)

        sut.update(localUserState: LocalUserState(participantRole: .consumer),
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertFalse(sut.isDisplayed)

        sut.update(localUserState: LocalUserState(participantRole: .uninitialized),
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertFalse(sut.isDisplayed)
    }

    func test_infoHeaderViewModel_update_when_participantInfoListHasLobbyParticipantsRoleWithNoPermissionToAdmitThenWith_then_shouldBeDisplayed() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should display")
        sut.$isDisplayed
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
            }).store(in: cancellable)

        let participantInfoModel: [ParticipantInfoModel] = makeParticipants([.inLobby])
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        let localUserState = LocalUserState(participantRole: .consumer)

        sut.update(localUserState: localUserState,
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertFalse(sut.isDisplayed)

        sut.update(localUserState: LocalUserState(participantRole: .presenter),
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertTrue(sut.isDisplayed)
        wait(for: [expectation], timeout: 1)

        sut.update(localUserState: LocalUserState(participantRole: .uninitialized),
                   remoteParticipantsState: remoteParticipantsState,
                   callingState: CallingState(),
                   visibilityState: VisibilityState())

        XCTAssertFalse(sut.isDisplayed)
    }
}

extension LobbyWaitingHeaderViewModelTests {
    func makeSUT(
                 accessibilityProvider: AccessibilityProviderProtocol = AccessibilityProvider(),
                 localizationProvider: LocalizationProviderMocking? = nil) -> LobbyWaitingHeaderViewModel {
        return LobbyWaitingHeaderViewModel(compositeViewModelFactory: factoryMocking,
                                           logger: logger,
                                           localUserState: LocalUserState(),
                                           localizationProvider: localizationProvider ?? LocalizationProvider(logger: logger),
                                           accessibilityProvider: accessibilityProvider,
                                           dispatchAction: storeFactory.store.dispatch)
    }

    func makeSUTLocalizationMocking() -> LobbyWaitingHeaderViewModel {
        return makeSUT(localizationProvider: localizationProvider)
    }

    func makeParticipants(_ statuses: [ParticipantStatus]) -> [ParticipantInfoModel] {
        statuses.enumerated().map { (index, status) in
            ParticipantInfoModel(
                displayName: "Participant \(index)",
                isSpeaking: false,
                isMuted: false,
                isRemoteUser: true,
                userIdentifier: "testUserIdentifier\(index)",
                status: status,
                screenShareVideoStreamModel: nil,
                cameraVideoStreamModel: nil)
        }
    }
}

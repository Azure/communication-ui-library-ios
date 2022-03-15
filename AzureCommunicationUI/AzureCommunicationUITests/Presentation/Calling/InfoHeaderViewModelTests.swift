//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class InfoHeaderViewModelTests: XCTestCase {

    var storeFactory: StoreFactoryMocking!
    var cancellable: CancelBag!
    var infoHeaderViewModel: InfoHeaderViewModel!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()

        func dispatch(action: Action) {
            storeFactory.store.dispatch(action: action)
        }
    }

    func test_infoHeaderViewModel_update_when_participantInfoListCountSame_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Should not publish infoLabel")
        expectation.isInverted = true
        let sut = makeSUT()
        sut.$infoLabel
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("participantInfoList count is same and infoLabel should not publish")
            }).store(in: cancellable)

        let participantInfoModel: [ParticipantInfoModel] = []
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        sut.update(localUserState: storeFactory.store.state.localUserState,
                                   remoteParticipantsState: remoteParticipantsState)

        XCTAssertEqual(sut.infoLabel, "Waiting for others to join")
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_update_when_participantInfoListCountChanged_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish infoLabel")
        let sut = makeSUT()
        sut.$infoLabel
            .dropFirst()
            .sink(receiveValue: { infoLabel in
                XCTAssertEqual(infoLabel, "Call with 1 person")
                expectation.fulfill()
            }).store(in: cancellable)

        let participantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: [participantInfoModel], lastUpdateTimeStamp: Date())

        XCTAssertEqual(sut.infoLabel, "Waiting for others to join")
        sut.update(localUserState: storeFactory.store.state.localUserState,
                                   remoteParticipantsState: remoteParticipantsState)
        XCTAssertEqual(sut.infoLabel, "Call with 1 person")

        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_update_when_multipleParticipantInfoListCountChanged_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish infoLabel")
        let sut = makeSUT()
        sut.$infoLabel
            .dropFirst()
            .sink(receiveValue: { infoLabel in
                XCTAssertEqual(infoLabel, "Call with 2 people")
                expectation.fulfill()
            }).store(in: cancellable)

        var participantList: [ParticipantInfoModel] = []
        let firstParticipantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        participantList.append(firstParticipantInfoModel)

        let secondParticipantInfoModel = ParticipantInfoModel(
            displayName: "Participant 2",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        participantList.append(secondParticipantInfoModel)

        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantList, lastUpdateTimeStamp: Date())

        XCTAssertEqual(sut.infoLabel, "Waiting for others to join")
        sut.update(localUserState: storeFactory.store.state.localUserState,
                                   remoteParticipantsState: remoteParticipantsState)
        XCTAssertEqual(sut.infoLabel, "Call with 2 people")

        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_when_displayParticipantsList_then_participantsListDisplayed() {
        let sut = makeSUT()
        sut.displayParticipantsList()

        XCTAssertTrue(sut.isParticipantsListDisplayed)
    }

    func test_infoHeaderViewModel_toggleDisplayInfoHeader_when_isInfoHeaderDisplayedFalse_then_shouldBecomeTrueAndPublish() {
        let expectation = XCTestExpectation(description: "Should publish isInfoHeaderDisplayed true")
        let sut = makeSUT()
        let cancel = sut.$isInfoHeaderDisplayed
            .dropFirst(2)
            .sink(receiveValue: { isInfoHeaderDisplayed in
                XCTAssertTrue(isInfoHeaderDisplayed)
                expectation.fulfill()
            })

        sut.isInfoHeaderDisplayed = false
        XCTAssertFalse(sut.isInfoHeaderDisplayed)
        sut.toggleDisplayInfoHeaderIfNeeded()
        XCTAssertTrue(sut.isInfoHeaderDisplayed)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_toggleDisplayInfoHeader_when_isInfoHeaderDisplayedFalse_then_isTrueAndWaitForTimerToHide_shouldBecomeFalseAgainAndPublish() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish isInfoHeaderDisplayed true")
        sut.$isInfoHeaderDisplayed
            .dropFirst(3)
            .sink(receiveValue: { isInfoHeaderDisplayed in
                XCTAssertFalse(isInfoHeaderDisplayed)
                expectation.fulfill()
            }).store(in: cancellable)

        sut.isInfoHeaderDisplayed = false
        XCTAssertFalse(sut.isInfoHeaderDisplayed)
        sut.toggleDisplayInfoHeaderIfNeeded()
        XCTAssertTrue(sut.isInfoHeaderDisplayed)
        wait(for: [expectation], timeout: 5)
    }

    func test_infoHeaderViewModel_toggleDisplayInfoHeader_when_isInfoHeaderDisplayedTrue_then_shouldBecomeFalseAndPublish() {
        let expectation = XCTestExpectation(description: "Should publish isInfoHeaderDisplayed false")
        let sut = makeSUT()
        let cancel = sut.$isInfoHeaderDisplayed
            .dropFirst(2)
            .sink(receiveValue: { isInfoHeaderDisplayed in
                XCTAssertFalse(isInfoHeaderDisplayed)
                expectation.fulfill()
            })

        sut.isInfoHeaderDisplayed = true
        XCTAssertTrue(sut.isInfoHeaderDisplayed)
        sut.toggleDisplayInfoHeaderIfNeeded()
        XCTAssertFalse(sut.isInfoHeaderDisplayed)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_init_then_subscribedToVoiceOverStatusDidChangeNotification() {
        let expectation = XCTestExpectation(description: "Should subscribe to VoiceOverStatusDidChange notification")
        let accessibilityProvider = AccessibilityProviderMocking()
        accessibilityProvider.subscribeToVoiceOverStatusDidChangeNotificationBlock = { object in
            XCTAssertNotNil(object)
            expectation.fulfill()
        }
        _ = makeSUT(accessibilityProvider: accessibilityProvider)
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_didChangeVoiceOverStatus_when_notificationReceived_and_infoHeadeHidden_then_infoHeaderShown() {
        let accessibilityProvider = AccessibilityProviderMocking()
        accessibilityProvider.isVoiceOverEnabled = false
        let sut = makeSUT(accessibilityProvider: accessibilityProvider)
        sut.toggleDisplayInfoHeaderIfNeeded()
        XCTAssertFalse(sut.isInfoHeaderDisplayed)
        accessibilityProvider.isVoiceOverEnabled = true
        sut.didChangeVoiceOverStatus(NSNotification(name: UIAccessibility.voiceOverStatusDidChangeNotification,
                                                    object: nil))
        XCTAssertTrue(sut.isInfoHeaderDisplayed)
    }
}

extension InfoHeaderViewModelTests {
    func makeSUT(accessibilityProvider: AccessibilityProvider = AppAccessibilityProvider()) -> InfoHeaderViewModel {
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        return InfoHeaderViewModel(compositeViewModelFactory: factoryMocking,
                                   logger: LoggerMocking(),
                                   localUserState: LocalUserState(),
                                   accessibilityProvider: accessibilityProvider)
    }
}

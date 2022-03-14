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
    var localizationProvider: LocalizationProvider!

    override func setUp() {
        super.setUp()
        storeFactory = StoreFactoryMocking()
        cancellable = CancelBag()
        localizationProvider = AppLocalizationProvider(logger: LoggerMocking())

        func dispatch(action: Action) {
            storeFactory.store.dispatch(action: action)
        }

        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        infoHeaderViewModel = InfoHeaderViewModel(compositeViewModelFactory: factoryMocking,
                                                  logger: LoggerMocking(),
                                                  localUserState: LocalUserState(),
                                                  localizationProvider: localizationProvider)
    }

    func test_infoHeaderViewModel_update_when_participantInfoListCountSame_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Should not publish infoLabel")
        expectation.isInverted = true
        infoHeaderViewModel.$infoLabel
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("participantInfoList count is same and infoLabel should not publish")
            }).store(in: cancellable)

        let participantInfoModel: [ParticipantInfoModel] = []
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        infoHeaderViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                   remoteParticipantsState: remoteParticipantsState)

        XCTAssertEqual(infoHeaderViewModel.infoLabel, "Waiting for others to join")
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_update_when_participantInfoListCountChanged_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish infoLabel")
        infoHeaderViewModel.$infoLabel
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

        XCTAssertEqual(infoHeaderViewModel.infoLabel, "Waiting for others to join")
        infoHeaderViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                   remoteParticipantsState: remoteParticipantsState)
        XCTAssertEqual(infoHeaderViewModel.infoLabel, "Call with 1 person")

        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_update_when_multipleParticipantInfoListCountChanged_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish infoLabel")
        infoHeaderViewModel.$infoLabel
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

        XCTAssertEqual(infoHeaderViewModel.infoLabel, "Waiting for others to join")
        infoHeaderViewModel.update(localUserState: storeFactory.store.state.localUserState,
                                   remoteParticipantsState: remoteParticipantsState)
        XCTAssertEqual(infoHeaderViewModel.infoLabel, "Call with 2 people")

        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_when_displayParticipantsList_then_participantsListDisplayed() {
        infoHeaderViewModel.displayParticipantsList()

        XCTAssertTrue(infoHeaderViewModel.isParticipantsListDisplayed)
    }

    func test_infoHeaderViewModel_toggleDisplayInfoHeader_when_isInfoHeaderDisplayedFalse_then_shouldBecomeTrueAndPublish() {
        let expectation = XCTestExpectation(description: "Should publish isInfoHeaderDisplayed true")
        let cancel = infoHeaderViewModel.$isInfoHeaderDisplayed
            .dropFirst(2)
            .sink(receiveValue: { isInfoHeaderDisplayed in
                XCTAssertTrue(isInfoHeaderDisplayed)
                expectation.fulfill()
            })

        infoHeaderViewModel.isInfoHeaderDisplayed = false
        XCTAssertFalse(infoHeaderViewModel.isInfoHeaderDisplayed)
        infoHeaderViewModel.toggleDisplayInfoHeader()
        XCTAssertTrue(infoHeaderViewModel.isInfoHeaderDisplayed)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }

    func test_infoHeaderViewModel_toggleDisplayInfoHeader_when_isInfoHeaderDisplayedFalse_then_isTrueAndWaitForTimerToHide_shouldBecomeFalseAgainAndPublish() {
        let expectation = XCTestExpectation(description: "Should publish isInfoHeaderDisplayed true")
        infoHeaderViewModel.$isInfoHeaderDisplayed
            .dropFirst(3)
            .sink(receiveValue: { isInfoHeaderDisplayed in
                XCTAssertFalse(isInfoHeaderDisplayed)
                expectation.fulfill()
            }).store(in: cancellable)

        infoHeaderViewModel.isInfoHeaderDisplayed = false
        XCTAssertFalse(infoHeaderViewModel.isInfoHeaderDisplayed)
        infoHeaderViewModel.toggleDisplayInfoHeader()
        XCTAssertTrue(infoHeaderViewModel.isInfoHeaderDisplayed)
        wait(for: [expectation], timeout: 5)
    }

    func test_infoHeaderViewModel_toggleDisplayInfoHeader_when_isInfoHeaderDisplayedTrue_then_shouldBecomeFalseAndPublish() {
        let expectation = XCTestExpectation(description: "Should publish isInfoHeaderDisplayed false")
        let cancel = infoHeaderViewModel.$isInfoHeaderDisplayed
            .dropFirst(2)
            .sink(receiveValue: { isInfoHeaderDisplayed in
                XCTAssertFalse(isInfoHeaderDisplayed)
                expectation.fulfill()
            })

        infoHeaderViewModel.isInfoHeaderDisplayed = true
        XCTAssertTrue(infoHeaderViewModel.isInfoHeaderDisplayed)
        infoHeaderViewModel.toggleDisplayInfoHeader()
        XCTAssertFalse(infoHeaderViewModel.isInfoHeaderDisplayed)
        cancel.cancel()
        wait(for: [expectation], timeout: 1)
    }
}

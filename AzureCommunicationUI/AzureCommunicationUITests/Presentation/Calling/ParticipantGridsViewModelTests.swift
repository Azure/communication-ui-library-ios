//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class ParticipantGridsViewModelTests: XCTestCase {
    var cancellable = CancelBag()

    // MARK: Sorting participant
    func test_participantGridsViewModel_updateParticipantsState_when_newSevenInfoModels_then_participantViewModelsSortedByRecentSpeakingTimeStamp() {
        var inputInfoModelArr = [ParticipantInfoModel]()
        for i in 0...6 {
            let date = Calendar.current.date(
                byAdding: .minute,
                value: i,
                to: Date())!
            inputInfoModelArr.append(ParticipantInfoModelBuilder.get(recentSpeakingStamp: date))
        }
        let lastUpdateTimeStamp = Calendar.current.date(
            byAdding: .minute,
            value: -2,
            to: Date())!
        let state = RemoteParticipantsState(participantInfoList: inputInfoModelArr,
                                            lastUpdateTimeStamp: lastUpdateTimeStamp)
        let sut = makeSUT()
        sut.update(remoteParticipantsState: state)
        guard let firstUserIdentifier = sut.participantsCellViewModelArr.first?.participantIdentifier,
              let expectedId = inputInfoModelArr.last?.userIdentifier else {
            XCTFail("Failed with empty userIdentifier")
            return
        }
        XCTAssertEqual(firstUserIdentifier, expectedId)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_existedTwoInfoModelsTimeStampUpdate_then_noIndexChange() {
        let previousDate = Calendar.current.date(
            byAdding: .minute,
            value: -2,
            to: Date())!
        let previousDate2 = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let uuid1 = UUID().uuidString
        let uuid2 = UUID().uuidString
        let infoModel1 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1,
                                                         recentSpeakingStamp: previousDate)
        let infoModel2 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid2,
                                                         recentSpeakingStamp: previousDate2)
        let state = RemoteParticipantsState(participantInfoList: [infoModel1, infoModel2],
                                            lastUpdateTimeStamp: previousDate2)
        let sut = makeSUT()
        sut.update(remoteParticipantsState: state)
        let expectedUserId = sut.participantsCellViewModelArr.first?.participantIdentifier
        let updatedStampInfoModel1 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1,
                                                                     recentSpeakingStamp: Date())

        let state2 = RemoteParticipantsState(participantInfoList: [updatedStampInfoModel1, infoModel2],
                                             lastUpdateTimeStamp: Date())
        sut.update(remoteParticipantsState: state2)
        guard let firstUserIdentifier = sut.participantsCellViewModelArr.first?.participantIdentifier else {
            XCTFail("Failed with empty participantIdentifier")
            return
        }
        XCTAssertEqual(firstUserIdentifier, expectedUserId)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_existedTwoInfoModelsSpeakingTimeStampChange_then_viewModelUpdated() {
        let previousDate = Calendar.current.date(
            byAdding: .minute,
            value: -2,
            to: Date())!
        let previousDate2 = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let uuid1 = UUID().uuidString
        let uuid2 = UUID().uuidString
        let infoModel1 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1,
                                                         isSpeaking: false, recentSpeakingStamp: previousDate)
        let infoModel2 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid2,
                                                         isSpeaking: false, recentSpeakingStamp: previousDate2)
        let state = RemoteParticipantsState(participantInfoList: [infoModel1, infoModel2],
                                            lastUpdateTimeStamp: previousDate2)
        let sut = makeSUT()
        sut.update(remoteParticipantsState: state)

        let expectedIsSpeaking = true
        let updatedStampInfoModel1 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1,
                                                                     isSpeaking: expectedIsSpeaking, recentSpeakingStamp: Date())
        let updatedStampInfoModel2 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid2,
                                                                     isSpeaking: expectedIsSpeaking, recentSpeakingStamp: previousDate2)

        let state2 = RemoteParticipantsState(participantInfoList: [updatedStampInfoModel1, updatedStampInfoModel2],
                                             lastUpdateTimeStamp: Date())
        sut.update(remoteParticipantsState: state2)
        guard let firstUserIsSpeaking = sut.participantsCellViewModelArr.first?.isSpeaking else {
            XCTFail("Failed with empty participantIdentifier")
            return
        }
        guard let secondUserIsSpeaking = sut.participantsCellViewModelArr.first?.isSpeaking else {
            XCTFail("Failed with empty participantIdentifier")
            return
        }
        XCTAssertEqual(firstUserIsSpeaking, expectedIsSpeaking)
        XCTAssertEqual(secondUserIsSpeaking, expectedIsSpeaking)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_screenSharing_then_screenSharingviewModelUpdated() {
        let uuid1 = UUID().uuidString
        let uuid2 = UUID().uuidString
        let expectedVideoStreamId = "screenshareVideoStream"
        let screenShareInfoModel = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1,
                                                                   screenShareStreamId: expectedVideoStreamId)
        let infoModel2 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid2)
        let state = RemoteParticipantsState(participantInfoList: [screenShareInfoModel, infoModel2],
                                            lastUpdateTimeStamp: Date())
        let sut = makeSUT()
        sut.update(remoteParticipantsState: state)
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.count, 1)
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.first!.userIdentifier, uuid1)
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.first!.screenShareVideoStreamModel?.videoStreamIdentifier, expectedVideoStreamId)
    }

    // MARK: LastUpdateTimeStamp
    func test_participantGridsViewModel_updateParticipantsState_when_viewModelLastUpdateTimeStampDifferent_then_updateRemoteParticipantCellViewModel() {
        let firstDate = Calendar.current.date(
            byAdding: .minute,
            value: -2,
            to: Date())
        let firstState = makeRemoteParticipantState(count: 1, date: firstDate!)
        let currentDate = Date()
        let expectedCount = 2
        let currentState = makeRemoteParticipantState(count: expectedCount, date: currentDate)
        let sut = makeSUT()
        sut.update(remoteParticipantsState: firstState)
        sut.update(remoteParticipantsState: currentState)
        XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_viewModelLastUpdateTimeStampSame_then_noUpdateRemoteParticipantCellViewModel() {
        let date = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())
        let expectedCount = 1

        let firstState = makeRemoteParticipantState(count: expectedCount, date: date!)
        let currentState = makeRemoteParticipantState(count: 2, date: date!)
        let sut = makeSUT()
        sut.update(remoteParticipantsState: firstState)
        sut.update(remoteParticipantsState: currentState)
        XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
    }

    // MARK: GridsViewType
    func test_participantGridsViewModel_init_then_gridsCountZero() {
        let expectation = XCTestExpectation(description: "subscription expection")
        let expectedGridCount = 0
        let sut = makeSUT()

        sut.$gridsCount
            .sink { value in
                XCTAssertEqual(expectedGridCount, value)
                expectation.fulfill()
            }.store(in: cancellable)
        sut.update(remoteParticipantsState: RemoteParticipantsState())
        wait(for: [expectation], timeout: 1)

    }

    func test_participantGridsViewModel_updateParticipantsState_when_oneRemoteParticipant_then_gridsCountSingle_onePaticipantsCellViewModel() {
        let expectation = XCTestExpectation(description: "subscription expection")
        let expectedGridCount = 1
        let sut = makeSUT()
        let expectedCount = 1
        sut.$gridsCount
            .dropFirst()
            .sink { value in
                XCTAssertEqual(expectedGridCount, value)
                XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
                expectation.fulfill()
            }.store(in: cancellable)
        sut.update(remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_twoRemoteParticipant_then_gridsCountTwo_twoPaticipantsCellViewModel() {
        let expectation = XCTestExpectation(description: "subscription expection")
        let expectedGridCount = 2
        let sut = makeSUT()
        let expectedCount = 2
        sut.$gridsCount
            .dropFirst()
            .sink { value in
                XCTAssertEqual(expectedGridCount, value)
                XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
                expectation.fulfill()
            }.store(in: cancellable)
        sut.update(remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_threeRemoteParticipant_then_gridsCountThree_threePaticipantsCellViewModel() {
        let expectation = XCTestExpectation(description: "subscription expection")
        let expectedGridCount = 3
        let sut = makeSUT()
        let expectedCount = 3
        sut.$gridsCount
            .dropFirst()
            .sink { value in
                XCTAssertEqual(expectedGridCount, value)
                XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
                expectation.fulfill()
            }.store(in: cancellable)
        sut.update(remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_fourRemoteParticipant_then_gridsCountFour_fourPaticipantsCellViewModel() {
        let expectation = XCTestExpectation(description: "subscription expection")
        let expectedGridCount = 4
        let sut = makeSUT()
        let expectedCount = 4
        sut.$gridsCount
            .dropFirst()
            .sink { value in
                XCTAssertEqual(expectedGridCount, value)
                XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
                expectation.fulfill()
            }.store(in: cancellable)
        sut.update(remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_fiveRemoteParticipant_then_gridsCountFive_fivePaticipantsCellViewModel() {
        let expectation = XCTestExpectation(description: "subscription expection")
        let expectedGridCount = 5
        let sut = makeSUT()
        let expectedCount = 5
        sut.$gridsCount
            .dropFirst()
            .sink { value in
                XCTAssertEqual(expectedGridCount, value)
                XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
                expectation.fulfill()
            }.store(in: cancellable)
        sut.update(remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_sixRemoteParticipant_then_gridsCountSix_sixPaticipantsCellViewModel() {
        let expectation = XCTestExpectation(description: "subscription expection")
        let expectedGridCount = 6
        let sut = makeSUT()
        let expectedCount = 6
        sut.$gridsCount
            .dropFirst()
            .sink { value in
                XCTAssertEqual(expectedGridCount, value)
                XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
                expectation.fulfill()
            }.store(in: cancellable)
        sut.update(remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_sevenRemoteParticipant_then_gridsCountSix_sixPaticipantsCellViewModel() {
        let expectation = XCTestExpectation(description: "subscription expection")
        let expectedGridCount = 6
        let sut = makeSUT()
        let expectedCount = 6
        sut.$gridsCount
            .dropFirst()
            .sink { value in
                XCTAssertEqual(expectedGridCount, value)
                XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
                expectation.fulfill()
            }.store(in: cancellable)
        sut.update(remoteParticipantsState: makeRemoteParticipantState(count: 7))
        wait(for: [expectation], timeout: 1)
    }

}

extension ParticipantGridsViewModelTests {
    func makeSUT() -> ParticipantGridViewModel {
        let storeFactory = StoreFactoryMocking()

        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(), store: storeFactory.store)
        return ParticipantGridViewModel(compositeViewModelFactory: factoryMocking)
    }

    func makeRemoteParticipantState(count: Int = 1,
                                    date: Date = Date()) -> RemoteParticipantsState {
        return RemoteParticipantsState(participantInfoList: ParticipantInfoModelBuilder.getArray(count: count),
                                       lastUpdateTimeStamp: date)
    }
}

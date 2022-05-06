//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUICalling

class ParticipantGridViewModelTests: XCTestCase {
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
        let callingState = CallingState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
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
        let callingState = CallingState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        let expectedUserId = sut.participantsCellViewModelArr.first?.participantIdentifier
        let updatedStampInfoModel1 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1,
                                                                     recentSpeakingStamp: Date())
        let state2 = RemoteParticipantsState(participantInfoList: [updatedStampInfoModel1, infoModel2],
                                             lastUpdateTimeStamp: Date())
        sut.update(callingState: callingState,
                   remoteParticipantsState: state2)
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
        let callingState = CallingState()
        let expectation = XCTestExpectation(description: "Participants list updated expectation")
        expectation.expectedFulfillmentCount = 2
        expectation.assertForOverFulfill = true
        let sut = makeSUT { _ in
            expectation.fulfill()
        }
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)

        let expectedIsSpeaking = true
        let updatedStampInfoModel1 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1,
                                                                     isSpeaking: expectedIsSpeaking, recentSpeakingStamp: Date())
        let updatedStampInfoModel2 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid2,
                                                                     isSpeaking: expectedIsSpeaking, recentSpeakingStamp: previousDate2)
        let updatedState = RemoteParticipantsState(participantInfoList: [updatedStampInfoModel1, updatedStampInfoModel2],
                                                   lastUpdateTimeStamp: Date())
        sut.update(callingState: callingState,
                   remoteParticipantsState: updatedState)
        wait(for: [expectation], timeout: 1)
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
        sut.update(callingState: CallingState(),
                   remoteParticipantsState: state)
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.count, 1)
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.first!.userIdentifier, uuid1)
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.first!.screenShareVideoStreamModel?.videoStreamIdentifier, expectedVideoStreamId)
    }

    // MARK: Updating participants list
    func test_participantGridsViewModel_updateParticipantsState_when_participantViewModelStateChanges_then_participantViewModelUpdated() {
        let date = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let state = makeRemoteParticipantState(date: date)
        let callingState = CallingState()
        let expectation = XCTestExpectation(description: "Participants list updated expectation")
        expectation.assertForOverFulfill = true
        let expectedUpdatedInfoModel = ParticipantInfoModelBuilder.get(participantIdentifier: state.participantInfoList.first!.userIdentifier,
                                                                       isMuted: !state.participantInfoList.first!.isMuted)
        let sut = makeSUT { infoModel in
            XCTAssertEqual(expectedUpdatedInfoModel, infoModel)
            expectation.fulfill()
        }
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        let updatedParticipantInfoList = [expectedUpdatedInfoModel]
        let updatedState = RemoteParticipantsState(participantInfoList: updatedParticipantInfoList)
        sut.update(callingState: callingState,
                   remoteParticipantsState: updatedState)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_participantViewModelStateChanges_then_participantViewModelsStaysTheSame() {
        let date = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let state = makeRemoteParticipantState(date: date)
        let callingState = CallingState()
        let expectation = XCTestExpectation(description: "Participants list updated expectation")
        expectation.assertForOverFulfill = true
        let expectedUpdatedInfoModel = ParticipantInfoModelBuilder.get(participantIdentifier: state.participantInfoList.first!.userIdentifier,
                                                                       isMuted: !state.participantInfoList.first!.isMuted)
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        guard let participant = sut.participantsCellViewModelArr.first else {
            XCTFail("Failed with empty participantsCellViewModelArr")
            return
        }
        let updatedParticipantInfoList = [expectedUpdatedInfoModel]
        let updatedState = RemoteParticipantsState(participantInfoList: updatedParticipantInfoList)
        sut.update(callingState: callingState,
                   remoteParticipantsState: updatedState)
        guard let updatedParticipant = sut.participantsCellViewModelArr.first else {
            XCTFail("Failed with empty participantsCellViewModelArr")
            return
        }
        XCTAssertIdentical(updatedParticipant, participant)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantAdded_then_participantViewModelAddedToList() {
        let date = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let state = makeRemoteParticipantState(date: date)
        let callingState = CallingState()
        let expectation = XCTestExpectation(description: "Participants list updated expectation")
        expectation.assertForOverFulfill = true
        let sut = makeSUT { _ in
            expectation.fulfill()
        }
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        guard let participant = sut.participantsCellViewModelArr.first else {
            XCTFail("Failed with empty participantsCellViewModelArr")
            return
        }
        let newParticipantInfoModel = ParticipantInfoModelBuilder.get()
        let updatedParticipantInfoList = [state.participantInfoList.first!,
                                          newParticipantInfoModel]
        let updatedState = RemoteParticipantsState(participantInfoList: updatedParticipantInfoList)
        sut.update(callingState: callingState,
                   remoteParticipantsState: updatedState)
        guard let newParticipant = sut.participantsCellViewModelArr.first(where: { $0.participantIdentifier != participant.participantIdentifier }) else {
            XCTFail("Failed to find ParticipantGridCellViewModel with the same participantIdentifier")
            return
        }
        XCTAssertEqual(newParticipant.participantIdentifier, newParticipantInfoModel.userIdentifier)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_someParticipantsChanged_then_participantViewModelsListUpdated() {
        let participantsInfoListCount = 3
        let state = makeRemoteParticipantState(count: participantsInfoListCount)
        let callingState = CallingState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        guard let participantInfo = state.participantInfoList.first else {
            XCTFail("Failed with empty participantsCellViewModelArr")
            return
        }
        let updatedInfoList = [participantInfo,
                               ParticipantInfoModelBuilder.get(),
                               ParticipantInfoModelBuilder.get()]
        let updatedState = RemoteParticipantsState(participantInfoList: updatedInfoList)
        sut.update(callingState: callingState,
                   remoteParticipantsState: updatedState)
        XCTAssertEqual(sut.participantsCellViewModelArr.count, updatedInfoList.count)
        XCTAssertEqual(sut.participantsCellViewModelArr.count, participantsInfoListCount)
        XCTAssertEqual(sut.participantsCellViewModelArr.map { $0.participantIdentifier }.sorted(),
                       updatedInfoList.map { $0.userIdentifier }.sorted())
    }

    func test_participantGridsViewModel_updateParticipantsState_when_participantRemoved_then_participantViewModelsUpdatedAndOrdeingNotChanged() {
        let participantsInfoListCount = 3
        let state = makeRemoteParticipantState(count: participantsInfoListCount)
        let callingState = CallingState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        var updatedInfoList = state.participantInfoList
        updatedInfoList.removeFirst()
        let updatedState = RemoteParticipantsState(participantInfoList: updatedInfoList)
        sut.update(callingState: callingState,
                   remoteParticipantsState: updatedState)
        XCTAssertEqual(sut.participantsCellViewModelArr.count, updatedInfoList.count)
        XCTAssertNotEqual(sut.participantsCellViewModelArr.count, participantsInfoListCount)
        XCTAssertEqual(sut.participantsCellViewModelArr.map { $0.participantIdentifier },
                       updatedInfoList.map { $0.userIdentifier })
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
        let callingState = CallingState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   remoteParticipantsState: firstState)
        sut.update(callingState: callingState,
                   remoteParticipantsState: currentState)
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
        let callingState = CallingState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   remoteParticipantsState: firstState)
        sut.update(callingState: callingState,
                   remoteParticipantsState: currentState)
        XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantsJoined_then_participantsJoinedAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let state = makeRemoteParticipantState(count: 2)
        let callingState = CallingState(status: .connected)
        let expectedAnnouncement = "2 participants joined the meeting"
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        let sut = makeSUT(accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantJoined_then_participantJoinedAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let state = makeRemoteParticipantState(count: 1)
        let callingState = CallingState(status: .connected)
        let displayName = state.participantInfoList.first!.displayName
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        let expectedAnnouncement = "\(displayName) joined the meeting"
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        let sut = makeSUT(accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_participantsLeft_then_participantsLeftAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let state = makeRemoteParticipantState(count: 4)
        let callingState = CallingState(status: .connected)
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        let expectedAnnouncement = "2 participants left the meeting"
        let sut = makeSUT(accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        let updatedState = RemoteParticipantsState(participantInfoList: state.participantInfoList.dropLast(2),
                                                   lastUpdateTimeStamp: Date())
        sut.update(callingState: callingState,
                   remoteParticipantsState: updatedState)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_participantLeft_then_participantLeftAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let state = makeRemoteParticipantState(count: 1)
        let callingState = CallingState(status: .connected)
        let displayName = state.participantInfoList.first!.displayName
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        let expectedAnnouncement = "\(displayName) left the meeting"
        let sut = makeSUT(accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        let updatedState = RemoteParticipantsState(participantInfoList: state.participantInfoList.dropLast(2),
                                                   lastUpdateTimeStamp: Date())
        sut.update(callingState: callingState,
                   remoteParticipantsState: updatedState)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_participantsListChanged_then_participantLeftAndJoinedAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        expectation.expectedFulfillmentCount = 2
        expectation.assertForOverFulfill = true
        let state = makeRemoteParticipantState(count: 2)
        let callingState = CallingState(status: .connected)
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        let sut = makeSUT(accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        sut.update(callingState: callingState,
                   remoteParticipantsState: state)
        accessibilityProvider.postQueuedAnnouncementBlock = { _ in
            expectation.fulfill()
        }
        let updatedState = makeRemoteParticipantState(count: 3)
        sut.update(callingState: callingState,
                   remoteParticipantsState: updatedState)
        wait(for: [expectation], timeout: 1)
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
        sut.update(callingState: CallingState(),
                   remoteParticipantsState: RemoteParticipantsState())
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
        sut.update(callingState: CallingState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
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
        sut.update(callingState: CallingState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
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
        sut.update(callingState: CallingState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
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
        sut.update(callingState: CallingState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
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
        sut.update(callingState: CallingState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
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
        sut.update(callingState: CallingState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount))
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
        sut.update(callingState: CallingState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: 7))
        wait(for: [expectation], timeout: 1)
    }
}

extension ParticipantGridViewModelTests {
    func makeSUT(participantGridCellViewUpdateCompletion: ((ParticipantInfoModel) -> Void)? = nil) -> ParticipantGridViewModel {
        let storeFactory = StoreFactoryMocking()
        let accessibilityProvider = AccessibilityProvider()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(),
                                                              store: storeFactory.store,
                                                              accessibilityProvider: accessibilityProvider)
        factoryMocking.createMockParticipantGridCellViewModel = { [unowned factoryMocking] infoModel in
            if let completion = participantGridCellViewUpdateCompletion {
                return ParticipantGridCellViewModelMocking(compositeViewModelFactory: factoryMocking,
                                                           participantModel: infoModel,
                                                           updateParticipantModelCompletion: completion)
            }
            return nil
        }
        return ParticipantGridViewModel(compositeViewModelFactory: factoryMocking,
        								localizationProvider: LocalizationProviderMocking(),
                                        accessibilityProvider: accessibilityProvider)
    }

    func makeSUT(accessibilityProvider: AccessibilityProviderProtocol,
                 localizationProvider: LocalizationProviderProtocol) -> ParticipantGridViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(),
                                                              store: storeFactory.store,
                                                              accessibilityProvider: accessibilityProvider)
        return ParticipantGridViewModel(compositeViewModelFactory: factoryMocking,
                                        localizationProvider: localizationProvider,
                                        accessibilityProvider: accessibilityProvider)
    }

    func makeRemoteParticipantState(count: Int = 1,
                                    date: Date = Date()) -> RemoteParticipantsState {
        return RemoteParticipantsState(participantInfoList: ParticipantInfoModelBuilder.getArray(count: count),
                                       lastUpdateTimeStamp: date)
    }
}

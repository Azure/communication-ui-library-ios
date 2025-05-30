//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class ParticipantGridViewModelTests: XCTestCase {
    var cancellable: CancelBag!

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
    }

    override func tearDown() {
        super.tearDown()
        cancellable = nil
    }

    func test_participantGridsViewModel_updateParticipantsState_whenDominantSpeakerNotChange_noIndexChange() {
        let date1 = Calendar.current.date(
            byAdding: .minute,
            value: -2,
            to: Date())!
        let date2 = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let uuid1 = UUID().uuidString
        let uuid2 = UUID().uuidString
        let uuid3 = UUID().uuidString
        let uuid4 = UUID().uuidString
        let uuid5 = UUID().uuidString
        let uuid6 = UUID().uuidString
        let uuid7 = UUID().uuidString
        let uuid8 = UUID().uuidString
        let infoModel1 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1)
        let infoModel2 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid2)
        let infoModel3 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid3)
        let infoModel4 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid4)
        let infoModel5 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid5)
        let infoModel6 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid6)
        let infoModel7 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid7)
        let infoModel8 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid8)
        let state = RemoteParticipantsState(participantInfoList: [infoModel1, infoModel2, infoModel3,
                                                                  infoModel4, infoModel5, infoModel6,
                                                                 infoModel7, infoModel8],
                                            dominantSpeakers: [uuid7, uuid2],
                                            dominantSpeakersModifiedTimestamp: date1)
        let callingState = CallingState()
        let captionsState = CaptionsState()
        let rttState = RttState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   captionsState: captionsState,
                   rttState: rttState,
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        let expectedUserId = sut.participantsCellViewModelArr.first?.participantIdentifier
        let state2 = RemoteParticipantsState(participantInfoList: [infoModel1, infoModel2, infoModel3,
                                                                  infoModel4, infoModel5, infoModel6,
                                                                 infoModel7, infoModel8],
                                             dominantSpeakers: [uuid7, uuid2],
                                             dominantSpeakersModifiedTimestamp: date2)
        sut.update(callingState: callingState,
                   captionsState: captionsState,
                   rttState: rttState,
                   remoteParticipantsState: state2,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        guard let firstUserIdentifier = sut.participantsCellViewModelArr.first?.participantIdentifier else {
            XCTFail("Failed with empty participantIdentifier")
            return
        }
        XCTAssertEqual(firstUserIdentifier, expectedUserId)
    }

    func test_participantGridsViewModel_updateParticipantsState_whenDominantSpeakerNotChangeButVideoStreamChange_indexChange() {
        let date1 = Calendar.current.date(
            byAdding: .minute,
            value: -2,
            to: Date())!
        let date2 = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let uuid1 = UUID().uuidString
        let uuid2 = UUID().uuidString
        let uuid3 = UUID().uuidString
        let uuid4 = UUID().uuidString
        let uuid5 = UUID().uuidString
        let uuid6 = UUID().uuidString
        let uuid7 = UUID().uuidString
        let uuid8 = UUID().uuidString
        let uuid9 = UUID().uuidString
        let uuid10 = UUID().uuidString
        let infoModel1 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1, videoStreamId: nil)
        let infoModel2 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid2, videoStreamId: nil)
        let infoModel3 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid3, videoStreamId: nil)
        let infoModel4 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid4, videoStreamId: nil)
        let infoModel5 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid5, videoStreamId: nil)
        let infoModel6 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid6, videoStreamId: nil)
        let infoModel7 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid7)
        let infoModel8 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid8, videoStreamId: nil)
        let state = RemoteParticipantsState(participantInfoList: [infoModel1, infoModel2, infoModel3,
                                                                  infoModel4, infoModel5, infoModel6,
                                                                 infoModel7, infoModel8],
                                            dominantSpeakers: [],
                                            dominantSpeakersModifiedTimestamp: date1)
        let callingState = CallingState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        let expectedUserId = uuid10
        let infoModel9 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid9, videoStreamId: nil)
        let infoModel10 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid10)
        let state2 = RemoteParticipantsState(participantInfoList: [infoModel1, infoModel10, infoModel3,
                                                                  infoModel4, infoModel5, infoModel6,
                                                                   infoModel9, infoModel8],
                                             dominantSpeakers: [],
                                             dominantSpeakersModifiedTimestamp: date2)
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state2,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        guard let firstUserIdentifier = sut.participantsCellViewModelArr.first?.participantIdentifier else {
            XCTFail("Failed with empty participantIdentifier")
            return
        }
        XCTAssertEqual(firstUserIdentifier, expectedUserId)
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.count, 1)
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.first!.userIdentifier, uuid1)
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.first!.screenShareVideoStreamModel?.videoStreamIdentifier, expectedVideoStreamId)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_someParticipantsInLobby_then_lobbyNotDisconnecteParticipantsNotDisplaydInGrid() {
        let uuid1 = UUID().uuidString
        let uuid2 = UUID().uuidString
        let uuid3 = UUID().uuidString

        let infoModel1 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid1, screenShareStreamId: nil)
        let infoModel2 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid2, screenShareStreamId: nil, status: .inLobby)
        let infoModel3 = ParticipantInfoModelBuilder.get(participantIdentifier: uuid3, screenShareStreamId: nil, status: .disconnected)

        let state = RemoteParticipantsState(participantInfoList: [infoModel1, infoModel2, infoModel3],
                                            lastUpdateTimeStamp: Date())
        let sut = makeSUT()
        sut.update(callingState: CallingState(),
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState())
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.count, 1)
        XCTAssertEqual(sut.displayedParticipantInfoModelArr.first!.userIdentifier, uuid1)
    }

    // MARK: Updating participants list
    func test_participantGridsViewModel_updateParticipantsState_when_participantViewModelStateChanges_then_participantViewModelUpdated() {
        let date = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let state = makeRemoteParticipantState(lastUpdatedTimeStamp: date)
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        let updatedParticipantInfoList = [expectedUpdatedInfoModel]
        let updatedState = RemoteParticipantsState(participantInfoList: updatedParticipantInfoList)
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: updatedState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_participantViewModelStateChanges_then_participantViewModelsStaysTheSame() {
        let date = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())!
        let state = makeRemoteParticipantState(lastUpdatedTimeStamp: date)
        let callingState = CallingState()
        let expectation = XCTestExpectation(description: "Participants list updated expectation")
        expectation.assertForOverFulfill = true
        let expectedUpdatedInfoModel = ParticipantInfoModelBuilder.get(participantIdentifier: state.participantInfoList.first!.userIdentifier,
                                                                       isMuted: !state.participantInfoList.first!.isMuted)
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        guard let participant = sut.participantsCellViewModelArr.first else {
            XCTFail("Failed with empty participantsCellViewModelArr")
            return
        }
        let updatedParticipantInfoList = [expectedUpdatedInfoModel]
        let updatedState = RemoteParticipantsState(participantInfoList: updatedParticipantInfoList)
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: updatedState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
        let state = makeRemoteParticipantState(lastUpdatedTimeStamp: date)
        let callingState = CallingState()
        let expectation = XCTestExpectation(description: "Participants list updated expectation")
        expectation.assertForOverFulfill = true
        let sut = makeSUT { _ in
            expectation.fulfill()
        }
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        guard let participant = sut.participantsCellViewModelArr.first else {
            XCTFail("Failed with empty participantsCellViewModelArr")
            return
        }
        let newParticipantInfoModel = ParticipantInfoModelBuilder.get()
        let updatedParticipantInfoList = [state.participantInfoList.first!,
                                          newParticipantInfoModel]
        let updatedState = RemoteParticipantsState(participantInfoList: updatedParticipantInfoList)
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: updatedState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        guard let participantInfo = state.participantInfoList.first else {
            XCTFail("Failed with empty participantsCellViewModelArr")
            return
        }
        let updatedInfoList = [participantInfo,
                               ParticipantInfoModelBuilder.get(),
                               ParticipantInfoModelBuilder.get()]
        let updatedState = RemoteParticipantsState(participantInfoList: updatedInfoList)
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: updatedState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        var updatedInfoList = state.participantInfoList
        updatedInfoList.removeFirst()
        let updatedState = RemoteParticipantsState(participantInfoList: updatedInfoList)
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: updatedState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
        let firstState = makeRemoteParticipantState(count: 1, lastUpdatedTimeStamp: firstDate!)
        let currentDate = Date()
        let expectedCount = 2
        let currentState = makeRemoteParticipantState(count: expectedCount, lastUpdatedTimeStamp: currentDate)
        let callingState = CallingState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: firstState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: currentState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantsRinging_then_participantsJoinedAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let state = makeRemoteParticipantState(count: 2)
        let callingState = CallingState(status: .ringing)
        let expectedAnnouncement = "2 participants joined the meeting"
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        let sut = makeSUT(callType: CompositeCallType.oneToNOutgoing,
                          accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantsConnecting_then_participantsJoinedAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let state = makeRemoteParticipantState(count: 2)
        let callingState = CallingState(status: .connecting)
        let expectedAnnouncement = "2 participants joined the meeting"
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        let sut = makeSUT(callType: CompositeCallType.oneToNOutgoing,
                          accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_viewModelLastUpdateTimeStampSame_then_noUpdateRemoteParticipantCellViewModel() {
        let date = Calendar.current.date(
            byAdding: .minute,
            value: -1,
            to: Date())
        let expectedCount = 1

        let firstState = makeRemoteParticipantState(count: expectedCount, lastUpdatedTimeStamp: date!,
                                                    dominantSpeakersModifiedTimestamp: date!)
        let currentState = makeRemoteParticipantState(count: 2, lastUpdatedTimeStamp: date!,
                                                      dominantSpeakersModifiedTimestamp: date!)
        let callingState = CallingState()
        let sut = makeSUT()
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: firstState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: currentState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        XCTAssertEqual(sut.participantsCellViewModelArr.count, expectedCount)
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        let updatedState = RemoteParticipantsState(participantInfoList: state.participantInfoList.dropLast(2),
                                                   lastUpdateTimeStamp: Date())
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: updatedState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        let updatedState = RemoteParticipantsState(participantInfoList: state.participantInfoList.dropLast(2),
                                                   lastUpdateTimeStamp: Date())
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: updatedState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: state,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        accessibilityProvider.postQueuedAnnouncementBlock = { _ in
            expectation.fulfill()
        }
        let updatedState = makeRemoteParticipantState(count: 3)
        sut.update(callingState: callingState,
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: updatedState,
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: RemoteParticipantsState(),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: expectedCount),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
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
                   captionsState: CaptionsState(),
                   rttState: RttState(),
                   remoteParticipantsState: makeRemoteParticipantState(count: 7),
                   visibilityState: VisibilityState(currentStatus: .visible),
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
        wait(for: [expectation], timeout: 1)
    }
}

extension ParticipantGridViewModelTests {
    func makeSUT(callType: CompositeCallType = .groupCall,
                 participantGridCellViewUpdateCompletion: ((ParticipantInfoModel) -> Void)? = nil) -> ParticipantGridViewModel {
        let storeFactory = StoreFactoryMocking()
        let accessibilityProvider = AccessibilityProvider()
        var factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(),
                                                              store: storeFactory.store,
                                                              accessibilityProvider: accessibilityProvider,
                                                              avatarManager: AvatarViewManagerMocking(
                                                                store: storeFactory.store,
                                                                localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                                                                localParticipantViewData: nil),
                                                              updatableOptionsManager: UpdatableOptionsManager(store: storeFactory.store, setupScreenOptions: nil, callScreenOptions: nil))
        factoryMocking.createMockParticipantGridCellViewModel = { infoModel in
            if let completion = participantGridCellViewUpdateCompletion {
                return ParticipantGridCellViewModelMocking(participantModel: infoModel,
                                                           updateParticipantModelCompletion: completion)
            }
            return nil
        }
        return ParticipantGridViewModel(compositeViewModelFactory: factoryMocking,
        								localizationProvider: LocalizationProviderMocking(),
                                        accessibilityProvider: accessibilityProvider,
                                        isIpadInterface: false,
                                        callType: callType,
                                        rendererViewManager: VideoViewManagerMocking())
    }

    func makeSUT(callType: CompositeCallType = .groupCall,
                 accessibilityProvider: AccessibilityProviderProtocol,
                 localizationProvider: LocalizationProviderProtocol) -> ParticipantGridViewModel {
        let storeFactory = StoreFactoryMocking()
        let factoryMocking = CompositeViewModelFactoryMocking(logger: LoggerMocking(),
                                                              store: storeFactory.store,
                                                              accessibilityProvider: accessibilityProvider,
                                                              avatarManager: AvatarViewManagerMocking(
                                                                store: storeFactory.store,
                                                                localParticipantId: createCommunicationIdentifier(fromRawId: ""),
                                                                localParticipantViewData: nil),
                                                              updatableOptionsManager: UpdatableOptionsManager(store: storeFactory.store, setupScreenOptions: nil, callScreenOptions: nil))
        return ParticipantGridViewModel(compositeViewModelFactory: factoryMocking,
                                        localizationProvider: localizationProvider,
                                        accessibilityProvider: accessibilityProvider,
                                        isIpadInterface: false,
                                        callType: callType,
                                        rendererViewManager: VideoViewManagerMocking())
    }

    func makeRemoteParticipantState(count: Int = 1,
                                    lastUpdatedTimeStamp: Date = Date(),
                                    dominantSpeakersModifiedTimestamp: Date = Date()) -> RemoteParticipantsState {
        return RemoteParticipantsState(participantInfoList: ParticipantInfoModelBuilder.getArray(count: count),
                                       lastUpdateTimeStamp: lastUpdatedTimeStamp,
                                       dominantSpeakersModifiedTimestamp: dominantSpeakersModifiedTimestamp)
    }
}

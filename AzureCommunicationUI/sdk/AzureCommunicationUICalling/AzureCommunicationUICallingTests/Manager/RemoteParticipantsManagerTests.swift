//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
import AzureCommunicationCommon
@testable import AzureCommunicationUICalling

class RemoteParticipantsManagerTests: XCTestCase {
    var sut: RemoteParticipantsManager!
    var avatarViewManager: AvatarViewManagerMocking!
    var mockStoreFactory: StoreFactoryMocking!
    var callingSDKWrapper: CallingSDKWrapperMocking!
    var eventsHandler: CallCompositeEventsHandling!
    var remoteParticipantsJoinedExpectation: XCTestExpectation!
    var expectedIds: [String] = []

    override func setUp() {
        super.setUp()
        sut = nil
        remoteParticipantsJoinedExpectation = XCTestExpectation(description: "DidRemoteParticipantsJoin event expectation")
        mockStoreFactory = StoreFactoryMocking()
        eventsHandler = CallCompositeEventsHandler()
        callingSDKWrapper = CallingSDKWrapperMocking()
        avatarViewManager = AvatarViewManagerMocking(store: mockStoreFactory.store,
                                                     localOptions: nil)
    }

    func test_remoteParticipantsManager_receive_when_stateUpdated_and_participantRemoved_then_avatarViewManagerUpdateStorageCalled() {
        let storageUpdatedExpectation = XCTestExpectation(description: "AvatarViewManager storage update expectation")
        makeSUT(isParticipantsJoinHandlerSet: false)
        let participant1 = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        let participant2 = ParticipantInfoModel(
            displayName: "Participant 2",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier2",
            status: .idle,
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        avatarViewManager.updateStorage = { ids in
            XCTAssertEqual(ids, [participant2.userIdentifier])
            storageUpdatedExpectation.fulfill()
        }
        let participants = [participant1, participant2]
        let state = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: participants))
        mockStoreFactory.setState(state)
        let updatedState = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: [participant1]))
        mockStoreFactory.setState(updatedState)
        wait(for: [storageUpdatedExpectation], timeout: 1)
    }

    func test_remoteParticipantsManager_receive_when_stateUpdated_and_noHandlerSet_then_didRemoteParticipantsJoinEventNotPosted() {
        makeSUT(isParticipantsJoinHandlerSet: false)
        remoteParticipantsJoinedExpectation.isInverted = true
        let participantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        expectedIds = [participantInfoModel.userIdentifier]
        let state = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: [participantInfoModel]))
        mockStoreFactory.setState(state)
        wait(for: [remoteParticipantsJoinedExpectation], timeout: 1)
    }

    func test_remoteParticipantsManager_receive_when_stateUpdated_then_didRemoteParticipantsJoinEventPosted() {
        makeSUT()
        let participantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        expectedIds = [participantInfoModel.userIdentifier]
        let state = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: [participantInfoModel]))

        mockStoreFactory.setState(state)
        wait(for: [remoteParticipantsJoinedExpectation], timeout: 1)
    }

    func test_remoteParticipantsManager_receive_when_participantsLastUpdateTimeStampNotChanged_then_didRemoteParticipantsJoinEventNotPosted() {
        makeSUT()
        let participantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        expectedIds = [participantInfoModel.userIdentifier]
        let state = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: [participantInfoModel]))
        remoteParticipantsJoinedExpectation.expectedFulfillmentCount = 1
        remoteParticipantsJoinedExpectation.assertForOverFulfill = true
        // initial state setup
        mockStoreFactory.setState(state)
        // final state setup
        mockStoreFactory.setState(state)
        wait(for: [remoteParticipantsJoinedExpectation], timeout: 1)
    }

    func test_remoteParticipantsManager_receive_when_participantsIdsNotChanged_then_didRemoteParticipantsJoinEventIsNotPosted() {
        makeSUT()
        let participantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            status: .idle,
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        expectedIds = [participantInfoModel.userIdentifier]
        let state = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: [participantInfoModel], lastUpdateTimeStamp: Date().addingTimeInterval(-1)))
        remoteParticipantsJoinedExpectation.expectedFulfillmentCount = 1
        remoteParticipantsJoinedExpectation.assertForOverFulfill = true
        // initial state setup
        mockStoreFactory.setState(state)
        let newState = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: [participantInfoModel]))
        // final state setup
        mockStoreFactory.setState(newState)
        wait(for: [remoteParticipantsJoinedExpectation], timeout: 1)
    }

    func test_remoteParticipantsManager_receive_when_participantLeftCall_then_didRemoteParticipantsJoinEventIsNotPosted() {
        makeSUT()
        var participantInfoModels: [ParticipantInfoModel] = []
        for i in 0...5 {
            participantInfoModels.append(ParticipantInfoModel(
                displayName: "Participant \(i)",
                isSpeaking: false,
                isMuted: false,
                isRemoteUser: true,
                userIdentifier: "testUserIdentifier\(i)",
                status: .idle,
                recentSpeakingStamp: Date(),
                screenShareVideoStreamModel: nil,
                cameraVideoStreamModel: nil))
        }
        expectedIds = participantInfoModels.map { $0.userIdentifier }
        let state = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: participantInfoModels, lastUpdateTimeStamp: Date().addingTimeInterval(-1)))
        remoteParticipantsJoinedExpectation.expectedFulfillmentCount = 1
        remoteParticipantsJoinedExpectation.assertForOverFulfill = true
        // initial state setup
        mockStoreFactory.setState(state)
        participantInfoModels.removeFirst(2)
        let newState = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: participantInfoModels))
        // final state setup
        mockStoreFactory.setState(newState)
        wait(for: [remoteParticipantsJoinedExpectation], timeout: 1)
    }
}

extension RemoteParticipantsManagerTests {
    func makeSUT(isParticipantsJoinHandlerSet: Bool = true) {
        if isParticipantsJoinHandlerSet {
            eventsHandler.didRemoteParticipantsJoin = { [weak self] _ in
                guard let self = self else {
                    return
                }
                // check getRemoteParticipantCallIds as there is no way to init RemoteParticipant for getRemoteParticipant func
                XCTAssertEqual(self.callingSDKWrapper.getRemoteParticipantCallIds.sorted(),
                               self.expectedIds.sorted())
                self.remoteParticipantsJoinedExpectation.fulfill()
            }
        }
        sut = RemoteParticipantsManager(store: mockStoreFactory.store,
                                        callCompositeEventsHandler: eventsHandler,
                                        callingSDKWrapper: callingSDKWrapper,
                                        avatarViewManager: avatarViewManager)
    }
}

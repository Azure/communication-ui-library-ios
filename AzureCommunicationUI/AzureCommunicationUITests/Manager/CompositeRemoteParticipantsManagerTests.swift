//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import AzureCommunicationUI

class CompositeRemoteParticipantsManagerTests: XCTestCase {
    var sut: CompositeRemoteParticipantsManager!
    var mockStoreFactory: StoreFactoryMocking!
    var eventsHandler: CallCompositeEventsHandling!
    var remoteParticipantsJoinedExpectation = XCTestExpectation(description: "DidRemoteParticipantsJoin event expectation")
    var expectedIds: [String] = []

    override func setUp() {
        super.setUp()
        mockStoreFactory = StoreFactoryMocking()
        eventsHandler = CallCompositeEventsHandler()
        let callingSDKEventsHandler = CallingSDKEventsHandlerMocking()
        eventsHandler.didRemoteParticipantsJoin = { [weak self] id in
            guard let self = self else {
                return
            }
            XCTAssertEqual(id.compactMap { $0.stringValue }.sorted(), self.expectedIds.sorted())
            self.remoteParticipantsJoinedExpectation.fulfill()
        }
        sut = CompositeRemoteParticipantsManager(store: mockStoreFactory.store,
                                                 callCompositeEventsHandler: eventsHandler,
                                                 callingSDKEventsHandling: callingSDKEventsHandler)
    }

    func test_compositeRemoteParticipantsManager_receive_when_stateUpdated_then_didRemoteParticipantsJoinEventPosted() {
        let participantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
            recentSpeakingStamp: Date(),
            screenShareVideoStreamModel: nil,
            cameraVideoStreamModel: nil)
        expectedIds = [participantInfoModel.userIdentifier]
        let state = AppState(remoteParticipantsState: RemoteParticipantsState(participantInfoList: [participantInfoModel]))

        mockStoreFactory.setState(state)
        wait(for: [remoteParticipantsJoinedExpectation], timeout: 1)
    }

    func test_compositeRemoteParticipantsManager_receive_when_participantsLastUpdateTimeStampNotChanged_then_didRemoteParticipantsJoinEventNotPosted() {
        let participantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
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

    func test_compositeRemoteParticipantsManager_receive_when_participantsIdsNotChanged_then_didRemoteParticipantsJoinEventIsNotPosted() {
        let participantInfoModel = ParticipantInfoModel(
            displayName: "Participant 1",
            isSpeaking: false,
            isMuted: false,
            isRemoteUser: true,
            userIdentifier: "testUserIdentifier1",
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

    func test_compositeRemoteParticipantsManager_receive_when_participantLeftCall_then_didRemoteParticipantsJoinEventIsNotPosted() {
        var participantInfoModels: [ParticipantInfoModel] = []
        for i in 0...5 {
            participantInfoModels.append(ParticipantInfoModel(
                displayName: "Participant \(i)",
                isSpeaking: false,
                isMuted: false,
                isRemoteUser: true,
                userIdentifier: "testUserIdentifier\(i)",
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

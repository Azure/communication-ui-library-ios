//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import XCTest

@testable import AzureCommunicationUICalling

class AccessibilityAnnouncementManagerTests: XCTestCase {
    private var cancellable: CancelBag!
    private var localizationProvider: LocalizationProviderMocking!
    private var storeFactory: StoreFactoryMocking!
    private var logger: LoggerMocking!
    private var factoryMocking: CompositeViewModelFactoryMocking!
    private let pA = ParticipantInfoModelBuilder.get(
        participantIdentifier: "T1",
        displayName: "Test1"
    )

    private let pB = ParticipantInfoModelBuilder.get(
        participantIdentifier: "T2",
        displayName: "Test2"
    )

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
        localizationProvider = LocalizationProviderMocking()
        storeFactory = StoreFactoryMocking()
        logger = LoggerMocking()
        factoryMocking = CompositeViewModelFactoryMocking(
            logger: logger, store: storeFactory.store,
            avatarManager: AvatarViewManagerMocking(
                store: storeFactory.store,
                localParticipantViewData: nil))
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantsJoined_then_participantsJoinedAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let expectedAnnouncement = "2 participants joined the meeting"
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())

        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        storeFactory.setState(makeState(count: 0))
        let sut = makeSUT(accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        storeFactory.setState(makeState(count: 2))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantsRinging_then_participantsJoinedAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let expectedAnnouncement = "2 participants joined the meeting"
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        storeFactory.setState(makeState(count: 0, callType: .oneToNOutgoing, callStatus: .ringing))
        let sut = makeSUT(accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        storeFactory.setState(makeState(count: 2, callType: .oneToNOutgoing, callStatus: .ringing))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantsConnecting_then_participantsJoinedAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let expectedAnnouncement = "2 participants joined the meeting"
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        storeFactory.setState(makeState(count: 0, callType: .oneToNOutgoing, callStatus: .connecting))
        let sut = makeSUT(accessibilityProvider: accessibilityProvider,
                          localizationProvider: localizationProvider)
        storeFactory.setState(makeState(count: 2, callType: .oneToNOutgoing, callStatus: .connecting))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantJoined_then_participantJoinedAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let state = makeRemoteParticipantState(count: 1)
        let displayName = state.participantInfoList.first!.displayName
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        let expectedAnnouncement = "\(displayName) joined the meeting"

        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        storeFactory.setState(makeState(count: 0))
        let sut = makeSUT(accessibilityProvider: accessibilityProvider, localizationProvider: localizationProvider)
        storeFactory.setState(makeState(count: 1))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_newParticipantJoined_then_participantLeftAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let state = makeRemoteParticipantState(count: 1)
        let displayName = state.participantInfoList.first!.displayName
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        let expectedAnnouncement = "\(displayName) left the meeting"

        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        storeFactory.setState(makeState(count: 1))
        let sut = makeSUT(accessibilityProvider: accessibilityProvider, localizationProvider: localizationProvider)
        storeFactory.setState(makeState(count: 0))
        wait(for: [expectation], timeout: 1)
    }

    func test_participantGridsViewModel_updateParticipantsState_when_participantsLeft_then_participantsLeftAnnouncementPosted() {
        let expectation = XCTestExpectation(description: "Announcement expection")
        let accessibilityProvider = AccessibilityProviderMocking()
        let localizationProvider = LocalizationProvider(logger: LoggerMocking())
        let expectedAnnouncement = "2 participants left the meeting"
        storeFactory.setState(makeState(count: 2))
        let sut = makeSUT(accessibilityProvider: accessibilityProvider, localizationProvider: localizationProvider)
        storeFactory.setState(makeState(count: 0))

        accessibilityProvider.postQueuedAnnouncementBlock = { message in
            XCTAssertEqual(message, expectedAnnouncement)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

}

extension AccessibilityAnnouncementManagerTests {
    func makeSUT(
        accessibilityProvider: AccessibilityProviderProtocol,
        localizationProvider: LocalizationProviderProtocol
    ) -> AccessibilityAnnouncementManager {
        // Force the Store into "Connected"
        return AccessibilityAnnouncementManager(
            store: storeFactory.store,
            accessibilityProvider: accessibilityProvider,
            localizationProvider: localizationProvider)
    }

    private func makeRemoteParticipantState(
        count: Int = 1,
        lastUpdatedTimeStamp: Date = Date(),
        dominantSpeakersModifiedTimestamp: Date = Date()) -> RemoteParticipantsState {
        return RemoteParticipantsState(participantInfoList: ParticipantInfoModelBuilder.getArray(count: count),
                                       lastUpdateTimeStamp: lastUpdatedTimeStamp,
                                       dominantSpeakersModifiedTimestamp: dominantSpeakersModifiedTimestamp)
    }

    func makeState(count: Int = 1,
                   callType: CompositeCallType = .groupCall,
                   callStatus: CallingStatus = .connected) -> AppState {
        return AppState(
            callingState: CallingState(callType: callType, status: callStatus),
            remoteParticipantsState: makeRemoteParticipantState(count: count)
        )
    }
}

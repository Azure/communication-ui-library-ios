//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class ParticipantsListViewModelTests: XCTestCase {
    var cancellable: CancelBag!
    var participantsListViewModel: ParticipantsListViewModel!

    override func setUp() {
        cancellable = CancelBag()
        participantsListViewModel = ParticipantsListViewModel(localUserState: LocalUserState())
    }

    // MARK: localParticipantsListCellViewModel test
    func test_participantsListViewModel_update_when_localUserStateMicOnAndUpdateWithMicOff_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish localParticipantsListCellViewModel")
        participantsListViewModel.$localParticipantsListCellViewModel
            .dropFirst(2)
            .sink(receiveValue: { participantsListCellViewModel in
                XCTAssertTrue(participantsListCellViewModel.isMuted)
                expectation.fulfill()
            }).store(in: cancellable)

        let audioStateOff = LocalUserState.AudioState(operation: .off,
                                                      device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioStateOff)
        let participantInfoModel: [ParticipantInfoModel] = []
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        let audioStateOn = LocalUserState.AudioState(operation: .on,
                                                     device: .receiverSelected)
        participantsListViewModel.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOn))
        XCTAssertFalse(participantsListViewModel.localParticipantsListCellViewModel.isMuted)
        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertTrue(participantsListViewModel.localParticipantsListCellViewModel.isMuted)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantsListViewModel_update_when_localUserStateMicOnAndUpdateWithMicOn_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Should not publish localParticipantsListCellViewModel")
        expectation.isInverted = true
        participantsListViewModel.$localParticipantsListCellViewModel
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("micStatus is same and localParticipantsListCellViewModel should not publish")
            }).store(in: cancellable)

        let audioStateOn = LocalUserState.AudioState(operation: .on,
                                                     device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioStateOn)
        let participantInfoModel: [ParticipantInfoModel] = []
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        participantsListViewModel.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOn))
        XCTAssertFalse(participantsListViewModel.localParticipantsListCellViewModel.isMuted)
        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertFalse(participantsListViewModel.localParticipantsListCellViewModel.isMuted)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantsListViewModel_update_when_localUserStateMicOffAndUpdateWithMicOn_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish localParticipantsListCellViewModel")
        participantsListViewModel.$localParticipantsListCellViewModel
            .dropFirst(2)
            .sink(receiveValue: { participantsListCellViewModel in
                XCTAssertFalse(participantsListCellViewModel.isMuted)
                expectation.fulfill()
            }).store(in: cancellable)

        let audioStateOn = LocalUserState.AudioState(operation: .on,
                                                     device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioStateOn)
        let participantInfoModel: [ParticipantInfoModel] = []
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        let audioStateOff = LocalUserState.AudioState(operation: .off,
                                                      device: .receiverSelected)
        participantsListViewModel.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOff))
        XCTAssertTrue(participantsListViewModel.localParticipantsListCellViewModel.isMuted)
        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertFalse(participantsListViewModel.localParticipantsListCellViewModel.isMuted)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantsListViewModel_update_when_localUserStateMicOffAndUpdateWithMicOff_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Should not publish localParticipantsListCellViewModel")
        expectation.isInverted = true
        participantsListViewModel.$localParticipantsListCellViewModel
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("micStatus is same and localParticipantsListCellViewModel should not publish")
            }).store(in: cancellable)

        let audioStateOff = LocalUserState.AudioState(operation: .off,
                                                      device: .receiverSelected)
        let localUserState = LocalUserState(audioState: audioStateOff)
        let participantInfoModel: [ParticipantInfoModel] = []
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: Date())

        participantsListViewModel.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOff))
        XCTAssertTrue(participantsListViewModel.localParticipantsListCellViewModel.isMuted)
        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertTrue(participantsListViewModel.localParticipantsListCellViewModel.isMuted)
        wait(for: [expectation], timeout: 1)
    }

    // MARK: participantsList test
    func test_participantsListViewModel_update_when_lastUpdateTimeStampChangedWithParticipantOrderCheck_then_shouldBePublished() {
        let expectation = XCTestExpectation(description: "Should publish localParticipantsListCellViewModel")
        participantsListViewModel.$participantsList
            .dropFirst()
            .sink(receiveValue: { participantsList in
                XCTAssertEqual(participantsList.count, 1)
                expectation.fulfill()
            }).store(in: cancellable)

        let audioStateOff = LocalUserState.AudioState(operation: .off,
                                                      device: .receiverSelected)
        let timestamp = Date()
        let localUserState = LocalUserState(audioState: audioStateOff)
        let participantInfoModel: [ParticipantInfoModel] = [
            ParticipantInfoModel(displayName: "User Name",
                                 isSpeaking: false,
                                 isMuted: false,
                                 isRemoteUser: false,
                                 userIdentifier: "MockUUID",
                                 recentSpeakingStamp: Date(),
                                 screenShareVideoStreamModel: nil,
                                 cameraVideoStreamModel: nil)
        ]
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: timestamp.addingTimeInterval(1))

        let audioStateOn = LocalUserState.AudioState(operation: .on,
                                                     device: .receiverSelected)
        participantsListViewModel.lastUpdateTimeStamp = timestamp
        let localParticipant = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOn))
        participantsListViewModel.localParticipantsListCellViewModel = localParticipant
        XCTAssertEqual(participantsListViewModel.participantsList.count, 0)
        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertEqual(participantsListViewModel.participantsList.count, 1)
        XCTAssertEqual(localParticipant.displayName, "(You)")
        XCTAssertEqual(participantsListViewModel.sortedParticipants().first?.displayName, localParticipant.displayName)
        XCTAssertEqual(participantsListViewModel.sortedParticipants().last?.displayName, remoteParticipantsState.participantInfoList.first!.displayName)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantsListViewModel_update_when_lastUpdateTimeStampNotChanged_then_shouldNotBePublished() {
        let expectation = XCTestExpectation(description: "Should not publish participantsList")
        expectation.isInverted = true
        participantsListViewModel.$participantsList
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
                XCTFail("lastUpdateTimeStamp is same and participantsList should not publish")
            }).store(in: cancellable)

        let audioStateOff = LocalUserState.AudioState(operation: .off,
                                                      device: .receiverSelected)
        let timestamp = Date()
        let localUserState = LocalUserState(audioState: audioStateOff)
        let participantInfoModel: [ParticipantInfoModel] = [
            ParticipantInfoModel(displayName: "User Name",
                                 isSpeaking: false,
                                 isMuted: false,
                                 isRemoteUser: false,
                                 userIdentifier: "MockUUID",
                                 recentSpeakingStamp: Date(),
                                 screenShareVideoStreamModel: nil,
                                 cameraVideoStreamModel: nil)
        ]
        let remoteParticipantsState = RemoteParticipantsState(
            participantInfoList: participantInfoModel, lastUpdateTimeStamp: timestamp)

        let audioStateOn = LocalUserState.AudioState(operation: .on,
                                                     device: .receiverSelected)
        participantsListViewModel.lastUpdateTimeStamp = timestamp
        participantsListViewModel.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOn))
        XCTAssertEqual(participantsListViewModel.participantsList.count, 0)
        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertEqual(participantsListViewModel.participantsList.count, 0)
        wait(for: [expectation], timeout: 1)
    }
}

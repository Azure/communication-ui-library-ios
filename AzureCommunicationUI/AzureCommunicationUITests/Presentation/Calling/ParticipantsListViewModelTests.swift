//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

class ParticipantsListViewModelTests: XCTestCase {
    var cancellable: CancelBag!
    var localizationProvider: LocalizationProviderMocking!

    override func setUp() {
        super.setUp()
        cancellable = CancelBag()
        localizationProvider = LocalizationProviderMocking()
    }

    // MARK: localParticipantsListCellViewModel test
    func test_participantsListViewModel_update_when_localUserStateMicOnAndUpdateWithMicOff_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish localParticipantsListCellViewModel")
        sut.$localParticipantsListCellViewModel
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
        sut.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOn),
            localizationProvider: localizationProvider)
        XCTAssertFalse(sut.localParticipantsListCellViewModel.isMuted)
        sut.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertTrue(sut.localParticipantsListCellViewModel.isMuted)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantsListViewModel_update_when_localUserStateMicOnAndUpdateWithMicOn_then_shouldNotBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should not publish localParticipantsListCellViewModel")
        expectation.isInverted = true
        sut.$localParticipantsListCellViewModel
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

        sut.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOn),
            localizationProvider: localizationProvider)
        XCTAssertFalse(sut.localParticipantsListCellViewModel.isMuted)
        sut.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertFalse(sut.localParticipantsListCellViewModel.isMuted)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantsListViewModel_update_when_localUserStateMicOffAndUpdateWithMicOn_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish localParticipantsListCellViewModel")
        sut.$localParticipantsListCellViewModel
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
        sut.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOff),
            localizationProvider: localizationProvider)
        XCTAssertTrue(sut.localParticipantsListCellViewModel.isMuted)
        sut.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertFalse(sut.localParticipantsListCellViewModel.isMuted)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantsListViewModel_update_when_localUserStateMicOffAndUpdateWithMicOff_then_shouldNotBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should not publish localParticipantsListCellViewModel")
        expectation.isInverted = true
        sut.$localParticipantsListCellViewModel
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

        sut.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOff),
            localizationProvider: localizationProvider)
        XCTAssertTrue(sut.localParticipantsListCellViewModel.isMuted)
        sut.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertTrue(sut.localParticipantsListCellViewModel.isMuted)
        wait(for: [expectation], timeout: 1)
    }

    // MARK: participantsList test
    func test_participantsListViewModel_update_when_lastUpdateTimeStampChangedWithParticipantOrderCheck_then_shouldBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should publish localParticipantsListCellViewModel")
        sut.$participantsList
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
        sut.lastUpdateTimeStamp = timestamp
        let localParticipant = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOn),
            localizationProvider: localizationProvider)
        sut.localParticipantsListCellViewModel = localParticipant
        XCTAssertEqual(sut.participantsList.count, 0)
        sut.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertEqual(sut.participantsList.count, 1)
        XCTAssertEqual(localParticipant.displayName, "")
        XCTAssertEqual(localParticipant.isLocalParticipant, true)
        XCTAssertEqual(sut.sortedParticipants().first?.displayName, localParticipant.displayName)
        XCTAssertEqual(sut.sortedParticipants().last?.displayName, remoteParticipantsState.participantInfoList.first!.displayName)
        wait(for: [expectation], timeout: 1)
    }

    func test_participantsListViewModel_update_when_lastUpdateTimeStampNotChanged_then_shouldNotBePublished() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Should not publish participantsList")
        expectation.isInverted = true
        sut.$participantsList
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
        sut.lastUpdateTimeStamp = timestamp
        sut.localParticipantsListCellViewModel = ParticipantsListCellViewModel(
            localUserState: LocalUserState(audioState: audioStateOn),
            localizationProvider: localizationProvider)
        XCTAssertEqual(sut.participantsList.count, 0)
        sut.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
        XCTAssertEqual(sut.participantsList.count, 0)
        wait(for: [expectation], timeout: 1)
    }
}

extension ParticipantsListViewModelTests {
    func makeSUT() -> ParticipantsListViewModel {
        return ParticipantsListViewModel(localUserState: LocalUserState(),
                                         localizationProvider: localizationProvider)
    }
}
